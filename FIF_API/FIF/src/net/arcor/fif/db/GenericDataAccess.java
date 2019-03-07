package net.arcor.fif.db;

import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;

import net.arcor.fif.common.FIFException;

public class GenericDataAccess extends DataAccess {

	private int maxUpdatedRows = 1;

	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public GenericDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public GenericDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
	
	@Override
	public void closeStatements() {
		return;
	}

	@Override
	public void init() throws FIFException {
		return;
	}

	public int getMaxUpdatedRows() {
		return maxUpdatedRows;
	}

	public void setMaxUpdatedRows(int maxUpdatedRows) {
		this.maxUpdatedRows = maxUpdatedRows;
	}

	/**
	 * executes a SELECT statement, no return value, practically useless now
	 * @throws FIFException
	 */
	public void executeSelectStatement(String statement) throws FIFException {
		Statement sqlStatement = null;
		try {
			sqlStatement = conn.createStatement();
			sqlStatement.execute(statement);
			sqlStatement.close();
		} catch (SQLException e) {
			throw new FIFException("SQLException (" + e.getErrorCode() + 
					"):" + e.getMessage(), e);
		} finally {
			if (sqlStatement != null)
				try {
					sqlStatement.close();
				} catch (Throwable t) {}
		}		
	}
	
	/**
	 * executes an INSERT, UPDATE or DELETE statement and checks the number of updated rows
	 * @param statement
	 * @throws FIFException
	 */
	public void executeDMLStatement(String statement) throws FIFException {
		Statement sqlStatement = null;
		try {
			sqlStatement = conn.createStatement();
			int updatedRows = sqlStatement.executeUpdate(statement);
			logger.info(updatedRows + " rows were updated with this statement.");
			// no updated rows doesn't make any sense for INSERT, UPDATE or DELETE statements, raise error
			if (updatedRows == 0) {
				throw new FIFException("No rows were updated with this statement.");
			}
			// too many updated rows
			else if (updatedRows > maxUpdatedRows)
				throw new FIFException("More rows (" + updatedRows + 
						") were updated with this statement than the maximum allowed (" + maxUpdatedRows + ").");
		} catch (SQLException e) {
			// Error returned by Oracle, just pass it through
			logger.info("SQLException: " + e.getMessage(), e);
			throw new FIFException("SQLException:" + e.getMessage(), e);
		} finally {
			if (sqlStatement != null)
				try {
					sqlStatement.close();
				} catch (Throwable t) {}
		}		
		
	}

	private void executeStatement(String statement) throws FIFException {
		logger.info("Executing the following statement: " + statement);
		// check for allowed statements. Everything else would be blocked.
		boolean isDML = 
			statement.trim().toUpperCase().startsWith("INSERT ") ||
			statement.trim().toUpperCase().startsWith("UPDATE ") ||
			statement.trim().toUpperCase().startsWith("DELETE ");

		if (!isDML)
			throw new FIFException("Only INSERT, UPDATE or DELETE statements (one statement per request) are allowed to be processed.");
		else 
			executeDMLStatement(statement);		
	}

	public synchronized void executeStatementList(LinkedList<String> statements) throws FIFException {
		try {
			for (String statement : statements)
				executeStatement(statement);
			conn.commit();
		}
		catch (SQLException e) {
			logger.fatal("Commit of transaction failed.", e);
		}
		catch (FIFException e) {
			try {
				conn.rollback();
			}
			catch (SQLException se) {}
			logger.error(e.getMessage());
			throw e;
		}
	}
	
}
