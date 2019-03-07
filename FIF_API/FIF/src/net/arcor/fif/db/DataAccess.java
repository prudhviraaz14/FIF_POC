package net.arcor.fif.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import net.arcor.fif.common.FIFException;

import oracle.sql.CLOB;

import org.apache.commons.dbcp.PoolableConnection;
import org.apache.log4j.Logger;

public abstract class DataAccess {

	/**
	 * The log4j logger.
	 */
	protected Logger logger = Logger.getLogger(getClass());
	
    /**
     * The connection to use for the database.
     */
	protected Connection conn = null;

	protected boolean initialized = false;

	/**
	 * @param dbAlias
	 * @throws SQLException 
	 * @throws SQLException
	 */
	private void createConnection(String dbAlias) throws FIFException {		
		try {
			if (conn == null) {
				conn = DriverManager.getConnection(DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + dbAlias);
				conn.setAutoCommit(false);
			}
		} catch (SQLException e) {
			throw new FIFException(e);
		}
	}

	public DataAccess() throws FIFException {
		createConnection("default");
	}

	public DataAccess(String dbAlias) throws FIFException {
		createConnection(dbAlias);
	}

	public DataAccess(Connection conn) throws FIFException {
		if (conn == null)
			throw new FIFException("NULL connection provided.");
		this.conn = (conn);
	}

    public abstract void init() throws FIFException;

    public abstract void closeStatements();

	public void commit() throws FIFException {
		try {
			conn.commit();
		} catch (SQLException e) {
			throw new FIFException(e);
		}
	}

	public void rollback() throws FIFException {
		try {
			conn.rollback();
		} catch (SQLException e) {
			throw new FIFException(e);
		}
	}

	/**
	 * @param fifTransaction
	 * @return
	 * @throws SQLException
	 */
	protected CLOB getClob(String content) throws SQLException {
		if (content == null)
			return null;
		CLOB newClob = CLOB.createTemporary(((PoolableConnection)conn).getDelegate(), false, oracle.sql.CLOB.DURATION_CALL);
		newClob.putString(1, content);
		return newClob;
	}

	public Connection getConn() {
		return conn;
	}
}
