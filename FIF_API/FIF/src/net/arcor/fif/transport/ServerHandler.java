/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/ServerHandler.java-arc   1.9   Jun 19 2015 15:00:30   schwarje  $
 *    $Revision:   1.9  $
 *    $Workfile:   ServerHandler.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jun 19 2015 15:00:30  $
 *
 *  Function: handles communication to the FIF backen process
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/ServerHandler.java-arc  $
 * 
 *    Rev 1.9   Jun 19 2015 15:00:30   schwarje
 * PPM-95514: improved handling of server crashes
 * 
 *    Rev 1.8   Jun 13 2015 11:01:24   schwarje
 * PPM-95514: allow to set working directory for running backend processes
 * 
 *    Rev 1.7   May 27 2011 10:34:14   wlazlow
 * SPN-FIF-000111192
 * SPN-CCB-000112640
 * 
 *    Rev 1.6   Mar 04 2010 18:41:08   schwarje
 * IT-26029: redesign of FIF clients
 * 
 *    Rev 1.5   Nov 10 2009 15:59:04   schwarje
 * IT-24000: fixed bug with "rubbish" returned from the backend
 * 
 *    Rev 1.4   Nov 05 2009 16:02:04   schwarje
 * SPN-FIF-000093205: restart backend process, if the specific error message is returned. Rerun the same request exactly once in this case.
 * 
 *    Rev 1.3   Dec 16 2008 11:36:00   makuier
 * Different instace name for main and recycle thread.
 * 
 *    Rev 1.2   May 16 2008 13:24:10   makuier
 * return null in case of server crash.
 * 
 *    Rev 1.1   Feb 06 2008 20:08:46   schwarje
 * IT-20058: update
 * 
 *    Rev 1.0   Feb 06 2008 12:40:28   makuier
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.transport;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFTechnicalException;

import org.apache.log4j.Logger;

public class ServerHandler {

    private static final String XML_START_STRING = "<?xml version";
    private static final String SERVER_READY = "*";
    private static final String NEW_LINE_PATTERN = ";;NewLine;;";
	/**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(ServerHandler.class);
    
    private Process ccmServerProcess;    // Child process
    private BufferedReader in = null;                  // FIFO connected to child process stdout
    private BufferedWriter out = null;                 // FIFO connected to child process stdin
    private BufferedReader error = null;
    private String ccmProcessName; 
    private String ccmInstanceName;
    private String ccmProcessArguments;
    private String ccmWorkingDirectory;
    private boolean simulateServer = false;
    private boolean simulateServerCrash = false;
    private boolean forceRestart = false;
    private boolean allowRestart = true;
    private String simulatedReplyFileName = null;    
    
	public ServerHandler() throws FIFException {
       ccmInstanceName = ClientConfig.getSetting("ServerHandler.ServerInstanceName");
       setupServer();
	}
	
	public ServerHandler(String instanceName) throws FIFException {
        ccmInstanceName = instanceName;
        setupServer();
 	}
	
	private void setupServer() throws FIFException{
		ccmProcessName = ClientConfig.getSetting("ServerHandler.ServerProcessName");
        ccmProcessArguments = ClientConfig.getSetting("ServerHandler.ServerArguments");

        try {
        	ccmWorkingDirectory = ClientConfig.getSetting("ServerHandler.WorkingDirectory");
        } catch (FIFException e) {}
        
		try {
			simulateServer = ClientConfig.getBoolean("ServerHandler.SimulateServer");
		} catch (FIFException e) {}

		try {
			forceRestart = ClientConfig.getBoolean("ServerHandler.ForceRestart");
		} catch (FIFException e) {}
		
		try {
			allowRestart = ClientConfig.getBoolean("ServerHandler.AllowRestart");
		} catch (FIFException e) {}
		
		if (simulateServer) {
			simulatedReplyFileName = ClientConfig.getSetting("ServerHandler.SimulatedReplyFileName");
			simulateServerCrash = ClientConfig.getBoolean("ServerHandler.SimulateServerCrash");
		}

		if (!simulateServer)
			forkChildProcess();
	}

	public String processMessage(String messageString, boolean restartOnParsingError) throws FIFException {
		
		if (simulateServer) {
			if (simulateServerCrash)
				return null;
			String output = null;
			try {
				File f = new File(simulatedReplyFileName);
				byte[] buffer = new byte[ (int) f.length() ]; 
				FileInputStream fr = new FileInputStream(simulatedReplyFileName);
				fr.read(buffer);
				output = new String(buffer); 
				fr.close();
			} catch (Exception e) {
				throw new FIFException("Exception while reading from file", e);
			}
			return output;
		}
		
        String serverReply = null;
        String serverStatus = null;
        String stderr = new String();
        
        logger.info("Sending MSG to server : ");

        try {
        	// Replace all new line characters
            logger.info(messageString);
            
        	String formattedMsg = messageString.replaceAll("\n", NEW_LINE_PATTERN) + "\n";
            // send XML request to child process CCM server
            out.write(formattedMsg, 0, formattedMsg.length());
            out.flush();

            logger.info("Waiting for server reply...");

            boolean receivedXML = false; 
            do {
                serverReply = in.readLine();
                if (serverReply != null) {
                	serverReply = serverReply.trim();
	                receivedXML = serverReply.startsWith(XML_START_STRING);
	                if (!receivedXML) {
	                    logger.info("Received non-XML data from server: " + serverReply + " -> skipping");
	                    if (!serverReply.equals(SERVER_READY))
	                    	stderr += serverReply + "\n";
	                }
                }
            } while (!receivedXML && serverReply != null);                       
            // Iona Orbix also barfs on stdout, we have to filter and check for XML            

            // Get the server status.
            serverStatus = in.readLine();
        }
        catch (NullPointerException npEx) {
        	logger.error("Exception:", npEx);
        }
        catch (IOException ioEx) {
        	logger.error("Exception:", ioEx);
        }
        
        if (serverReply == null || serverStatus == null) {
        	logger.warn("Closed FIFO detected due to child process termination -> Restarting Server");
        	forkChildProcess();
        	String errorText = "The server has crashed while processing request";
        	if (stderr.length() > 0)
        		errorText += " with the following error:\n" + stderr;
        	throw new FIFTechnicalException(FIFErrorLiterals.FIF0010, errorText);
        }
        
        if (serverReply != null) {
        	logger.info("server reply : " + serverReply);
            
        	// SPN-FIF-000093205
        	// Sometimes, the backend process produces masses of parsing error with random 
        	// line and column numbers. We assume, that Xerces has some memory trash. Therefore the 
        	// backend process will be restarted, if the following message is in the reply:
        	// CCM6020 An error occurred during parsing: . Line : 1651470188, Column : 541619814
        	if (serverReply.contains("1651470188") && 
        			serverReply.contains("541619814") && 
        			serverReply.contains("<error_type><![CDATA[XXXX]]></error_type>") &&
        			allowRestart 
        			|| forceRestart) {
        		restartServer();
        		if (restartOnParsingError) {      
        			logger.warn("Rerunning request on new backend process after parsing error.");
        			serverReply = processMessage(messageString, false);
        		}
        	}
        }
        
        return serverReply;
	}
	
    private void restartServer() throws FIFException {
    	logger.warn("Restarting backend process after parsing error due to memory trash.");
    	if (ccmServerProcess != null)
    		ccmServerProcess.destroy();
    	forkChildProcess();
	}

	/**
     * Fork server as a child process with supplied command line arguments and setup FIFO IPC channels 
     * between parent and child. IPC is performed via normal UNIX stdin/stdout pipes wrapped in 
     * Java IOStream objects.
     * @throws FIFException 
     */
    private void forkChildProcess() throws FIFException {
    
        try {
            // create child process (co-routine) 
            logger.info("Starting child: " + ccmProcessName);
            logger.info("  With instance name: " + (ccmInstanceName.length() == 0 ? "None specified" : ccmInstanceName));
            logger.info("  With additional command line arguments: " + ccmProcessArguments);
            
            //ccmServerProcess = Runtime.getRuntime().exec(ccmProcessName + " " + ccmInstanceName + " " + ccmProcessArguments);          
            ProcessBuilder builder = new ProcessBuilder(ccmProcessName,ccmInstanceName,ccmProcessArguments);
            if (ccmWorkingDirectory != null)
            	builder.directory(new File(ccmWorkingDirectory));
            builder.redirectErrorStream(true); 
            ccmServerProcess = builder.start(); 
            
            // attach io stream objects onto stdin and stdout
            InputStream pin = ccmServerProcess.getInputStream();
            InputStreamReader cin = new InputStreamReader(pin);
            if (in != null)
            	in.close();
            in = new BufferedReader(cin);

            OutputStream pout = ccmServerProcess.getOutputStream();
            OutputStreamWriter cout = new OutputStreamWriter(pout);
            out = new BufferedWriter(cout);
            
            InputStream perror = ccmServerProcess.getErrorStream();
            InputStreamReader cerror = new InputStreamReader(perror);
            if (error != null)
            	error.close();
            error = new BufferedReader(cerror);
        }
        catch (IOException ioEx) {
            if (ccmServerProcess != null) {
                ccmServerProcess.destroy(); // trash it, if any
            }
            throw new FIFException ("CCM process could not be started.", ioEx);
        }   
        
        if (ccmServerProcess == null)
        	throw new FIFException ("CCM process could not be started.");
    }
}
