package
{
	import poliroid.views.lobby.ModsSettingsApi;
	
	dynamic public class modsSettingsApi_UI extends ModsSettingsApi
	{
		
		public function modsSettingsApi_UI()
		{
			super();
			App.instance.loaderMgr.loadLibraries(Vector.<String>(["popovers.swf", "guiControlsLobbyBattleDynamic.swf"]));
		}
	
	}

}
