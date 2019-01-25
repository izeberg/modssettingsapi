package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.wg.gui.interfaces.ISoundButtonEx;
	import net.wg.gui.components.controls.SoundButtonEx;
	
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;
	
	public class StatusSwitcher extends SoundButtonEx implements ISoundButtonEx
	{
		
		private static const ICON_ENABLED:String = 'enabled';
		
		private static const ICON_DISABLED:String = 'disabled';
		
		public var icon:MovieClip = null;
		
		private var _enabled:Boolean = false;
		
		public function StatusSwitcher()
		{
			super();
		}
		
		override protected function handleMouseRollOver(event:MouseEvent) : void
		{
			App.toolTipMgr.showComplex(STRINGS.BUTTON_ENABLED_TOOLTIP);
			super.handleMouseRollOver(event);
		}
		
		override protected function handleMouseRollOut(event:MouseEvent) : void
		{
			super.handleMouseRollOut(event);
			App.toolTipMgr.hide();
		}
		
		public function set isEnabled(_isEnabled:Boolean) : void
		{
			if(isEnabled == _isEnabled)
			{
				return;
			}
			
			_enabled = _isEnabled;
			
			if(isEnabled)
			{
				icon.gotoAndStop(ICON_ENABLED);
			}
			else
			{
				icon.gotoAndStop(ICON_DISABLED);
			}
			
		}
		
		public function get isEnabled():Boolean
		{
			return _enabled;
		}
	}
}
