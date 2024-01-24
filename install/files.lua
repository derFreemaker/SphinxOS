return {
	"OS",
	{
		"boot",
		{ "10_core.lua" },
		{ "100_environment.lua" },
		{ "190_eventHandler.lua" },
		{ "20_utils.lua" },
		{ "200_start.lua" },
		{ "eeprom.lua" },
	},
	{
		"misc",
		{ "classSystem.lua" },
		{ "utils.lua" },
	},
	{
		"System",
		{
			"Adapter",
			{
				"Computer",
				{ "InternetCard.lua" },
				{ "NetworkCard.lua" },
			},
			{
				"Pipeline",
				{ "Valve.lua" },
			},
		},
		{
			"Data",
			{ "Cache.lua" },
		},
		{
			"Event",
			{ "EventPullHandler.lua" },
			{ "init.lua" },
		},
		{
			"FileSystem",
			{ "Path.lua" },
		},
		{
			"IO",
			{ "Buffer.lua" },
			{ "IBuffer.lua" },
			{ "IStream.lua" },
			{ "Stream.lua" },
		},
		{
			"Json",
			{ "init.lua" },
			{ "Serializable.lua" },
			{ "Serializer.lua" },
		},
		{
			"Logging",
			{ "Logger.lua" },
		},
		{
			"Net",
			{ "IPAddress.lua" },
			{ "StatusCodes.lua" },
		},
		{
			"References",
			{ "IReference.lua" },
			{ "PCIDeviceReference.lua" },
			{ "ProxyReference.lua" },
		},
		{
			"Threading",
			{ "Environment.lua" },
			{ "Process.lua" },
			{ "Task.lua" },
			{ "Thread.lua" },
		},
		{ "Require.lua" },
	},
}
