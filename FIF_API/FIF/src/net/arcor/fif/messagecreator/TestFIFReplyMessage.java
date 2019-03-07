/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestFIFReplyMessage.java-arc   1.2   Jun 14 2004 15:43:10   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestFIFReplyMessage.java-arc  $
 * 
 *    Rev 1.2   Jun 14 2004 15:43:10   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.1   Jul 16 2003 15:01:06   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:44   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Class containing the test cases for the FIFReplyMessage class
 * @author goethalo
 */
public class TestFIFReplyMessage extends TestCase {

    /**
     * Constructor for TestDatabaseClient.
     * @param arg0
     */
    public TestFIFReplyMessage(String arg0) {
        super(arg0);
    }

    /**
     * Tests the parsing of error messages in
     * a FIF reply message.
     */
    public void testErrorParsing() throws FIFException {
        // Create an FIF Response Message
        StringBuffer sb = new StringBuffer();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
        sb.append("<CcmFifCommandList>        \n");
        sb.append("<transaction_state><![CDATA[ROLLED_BACK]]></transaction_state>        \n");
        sb.append("  <CommandList>        \n");
        sb.append("    <CcmFifAddServiceSubsCmd>        \n");
        sb.append("      <CcmFifAddServiceSubsCmd_Out>        \n");
        sb.append("        <execution_state><![CDATA[FAILED]]></execution_state>        \n");
        sb.append("        <error_list>        \n");
        sb.append("          <error_element>        \n");
        sb.append("            <error_type><![CDATA[141292]]></error_type>        \n");
        sb.append("            <error_description><![CDATA[CCM1292 Caught HvfException in CCM Server.]]></error_description>        \n");
        sb.append("          </error_element>        \n");
        sb.append("          <error_element>        \n");
        sb.append("            <error_type><![CDATA[100257]]></error_type>\n");
        sb.append("            <error_description><![CDATA[HVF1008 HvfException, Reason: Tried all servers ([ psm/PSM_SVR_fif_wlazlow_ROUND_ROBIN@NameService ], [ psm/PSM_SVR_fif_wlazlow_ROUND_ROBIN@NameService ]) - giving up - reasons () [Thrown from </build_local/inc32iv66/DEVUG/INF/AclClientWrapper/AclClientWrapper.cpp> line <883>]]]></error_description>\n");
        sb.append("          </error_element>\n");
        sb.append("          <error_element>\n");
        sb.append("            <error_type><![CDATA[142688]]></error_type>\n");
        sb.append("            <error_description><![CDATA[CCM2688 No Service (CCM22) could be found for the Product Code (I0001) and the Product Version Code (5).]]></error_description>\n");
        sb.append("          </error_element>\n");
        sb.append("        </error_list>\n");
        sb.append("      </CcmFifAddServiceSubsCmd_Out>\n");
        sb.append("    </CcmFifAddServiceSubsCmd>\n");
        sb.append("    <CcmFifAddServiceSubsCmd2>\n");
        sb.append("      <CcmFifAddServiceSubsCmd2_Out>\n");
        sb.append("        <execution_state><![CDATA[SUCCESS]]></execution_state>\n");
        sb.append("      </CcmFifAddServiceSubsCmd2_Out>\n");
        sb.append("    </CcmFifAddServiceSubsCmd2>\n");
        sb.append("    <CcmFifAddServiceSubsCmd3>\n");
        sb.append("      <CcmFifAddServiceSubsCmd3_Out>\n");
        sb.append("        <execution_state><![CDATA[NOT EXECUTED]]></execution_state>\n");
        sb.append("      </CcmFifAddServiceSubsCmd3_Out>\n");
        sb.append("    </CcmFifAddServiceSubsCmd3>\n");
        sb.append("  </CommandList>\n");
        sb.append("</CcmFifCommandList>\n");

        FIFReplyMessage msg = new FIFReplyMessage();
        msg.setMessage(sb.toString());
        FIFTransactionResult result = msg.getResult();
        System.out.println(result.toString());

        if (!msg.isError() && msg.isValid()) {
            fail("Should have gotten error messages");
        }
        if (!msg.isValid()) {
            fail("Message is not valid.");
        }
    }

    /**
     * Defines the tests of this class as members of the test suite.
     * @return Test
     */
    public static Test suite() {
        return new TestSuite(TestFIFReplyMessage.class);
    }
}
