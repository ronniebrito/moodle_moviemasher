package net.sziebert.tutorials;

import org.red5.logging.Red5LoggerFactory;
import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IConnection;
import org.slf4j.Logger;

/**
 * <code>Application</code> is a simple <code>ApplicationAdapter</code>
 * delegate which gets a reference to the publishing stream, plays it into a
 * server stream and records it.
 */
public class Application extends ApplicationAdapter {
	
	private static final Logger logger = Red5LoggerFactory.getLogger(Application.class, "recorder");

	/* ----- ApplicationAdapter delegate methods ----- */

	/**
	 * Delegate method used to accept/reject incoming connection requests.
	 * 
	 * @param conn
	 * @param params
	 * @return true/false
	 */
	@Override
	public boolean roomConnect(IConnection conn, Object[] params) {
		logger.debug("New connection attempt from {}...", conn.getRemoteAddress());
		// Insure that the listeners are properly attached.
		return super.roomConnect(conn, params);
	}

	/**
	 * Delegate method which logs connection/client/user disconnections.
	 * 
	 * @param conn
	 */
	@Override
	public void roomDisconnect(IConnection conn) {
		logger.debug("Connection closed by {}...", conn.getRemoteAddress());
		// Call the super class to insure that all listeners are properly dismissed.
		super.roomDisconnect(conn);
	}

	/* ----- Application utility methods ----- */
}
