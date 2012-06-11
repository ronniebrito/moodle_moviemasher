<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Simple Broadcaster</title>
		<style>
			body {
				margin: 0;
				padding: 10px;
				background: #FFFFFF;
			}
			
			#viewer {
				margin: 0;
				padding: 0;
				width: 356px;
				height: 308px;
			}
		</style>
		<script type="text/javascript" src="flash_resize.js"></script>
		<script type="text/javascript" src="swfobject.js"></script>
	</head>
	<body>
		<div id="broadcaster">
			<strong>Your flash player appears to be out of date.  Please upgrade it.</strong>
		</div>
		<script type="text/javascript">
			// <![CDATA[
			<% String taskid= "testeeee";
			
			%>
			var so = new SWFObject("broadcast.swf", "broadcast", "100%", "100%", "8", "#FFFFFF");
			so.addVariable("userid", "<% out.print(taskid); %>");
			so.addVariable("taskid", "<% out.print(taskid); %>");
			so.addParam("allowScriptAccess", "always");
			so.addVariable("allowResize", canResizeFlash());
			so.write("broadcaster");
			
			// ]]>
		</script>
	</body>
</html>
