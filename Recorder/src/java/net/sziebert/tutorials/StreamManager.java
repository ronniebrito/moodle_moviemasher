package net.sziebert.tutorials;

import org.red5.logging.Red5LoggerFactory;
import org.red5.server.api.IConnection;
import org.red5.server.api.Red5;
import org.red5.server.api.stream.IBroadcastStream;
import org.red5.server.stream.ClientBroadcastStream;
import org.slf4j.Logger;

/**
 * <code>StreamManager</code> provides services for recording
 * the broadcast stream.
 */
public class StreamManager {

	private static final Logger logger = Red5LoggerFactory.getLogger(StreamManager.class, "recorder");

	// Application components
	private Application app;

	/**
	 * Start recording the publishing stream for the specified <code>IConnection</code>.
	 */
	public void recordShow() {
        IConnection conn = Red5.getConnectionLocal();
		logger.debug("Recording show for: {}", conn.getScope().getContextPath());
		String streamName = String.valueOf(System.currentTimeMillis());
		// Get a reference to the current broadcast stream.
		IBroadcastStream stream = app.getBroadcastStream(conn.getScope(), "hostStream");
		try {
			// Save the stream to disk.
			stream.saveAs(streamName, false);
		} catch (Exception e) {
			logger.error("Error while saving stream: {}", streamName);
		}
	}

	/**
	 * Stops recording the publishing stream for the specified <code>IConnection</code>.
	 */
	public void stopRecordingShow() {
        IConnection conn = Red5.getConnectionLocal();
		logger.debug("Stop recording show for: {}", conn.getScope().getContextPath());
		// Get a reference to the current broadcast stream.
		ClientBroadcastStream stream = (ClientBroadcastStream) app.getBroadcastStream(conn.getScope(), "hostStream");
		// Stop recording.
		stream.stopRecording();
	}

	/* ----- Spring injected dependencies ----- */

	public void setApplication(Application app) {
		this.app = app;
	}


/**
	 * Start recording the publishing stream for the specified <code>IConnection</code>.
	 */
	public void iniciarGravacao(String streamName ) {
        IConnection conn = Red5.getConnectionLocal();
		logger.debug("Recording show for: {}", conn.getScope().getContextPath());
		// Get a reference to the current broadcast stream.
		IBroadcastStream stream = app.getBroadcastStream(conn.getScope(), streamName);
		try {
			// Save the stream to disk.
			stream.saveAs(streamName, false);
		} catch (Exception e) {
			logger.error("Error while saving stream: {}", streamName);
		}
	}

/**
	 * Stops recording the publishing stream for the specified <code>IConnection</code>.
	 */
	public void pararGravacao(String streamName ) {
        IConnection conn = Red5.getConnectionLocal();
		logger.debug("Stop recording show for: {}", conn.getScope().getContextPath());
		// Get a reference to the current broadcast stream.
		ClientBroadcastStream stream = (ClientBroadcastStream) app.getBroadcastStream(conn.getScope(), streamName);
		// Stop recording.
		stream.stopRecording();
	}


}
