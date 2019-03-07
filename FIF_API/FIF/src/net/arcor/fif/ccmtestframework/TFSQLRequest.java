package net.arcor.fif.ccmtestframework;

import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.messagecreator.Request;

/**
* @author schwarje
*
*/
public class TFSQLRequest extends Request {

/*------------------*
 * MEMBER VARIABLES *
 *------------------*/

	private Map outputParams = null;

	private Map resultParams = null;
	
	private String statement;
	
	private String transactionId;;
	
/*--------------*
 * CONSTRUCTORS *
 *--------------*/

/**
 * Constructor.
 */
public TFSQLRequest() {
    super();
    outputParams = new HashMap();
    resultParams = new HashMap();
}

/*---------------------*
 * GETTERS AND SETTERS *
 *---------------------*/

public Map getOutputParams() {
	return outputParams;
}

public void setOutputParams(Map outputParams) {
	this.outputParams = outputParams;
}

public Map getResultParams() {
	return resultParams;
}

public void setResultParams(Map resultParams) {
	this.resultParams = resultParams;
}

public String getStatement() {
	return statement;
}

public void setStatement(String statement) {
	this.statement = statement;
}

public String getTransactionId() {
	return transactionId;
}

public void setTransactionId(String transactionId) {
	this.transactionId = transactionId;
}


}
