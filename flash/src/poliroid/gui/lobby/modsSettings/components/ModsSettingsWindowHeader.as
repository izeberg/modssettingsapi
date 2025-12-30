package poliroid.gui.lobby.modsSettings.components
{
	import flash.text.TextField;
	import scaleform.clik.events.ButtonEvent;
	import net.wg.gui.components.controls.CloseButtonText;
	import net.wg.infrastructure.base.UIComponentEx;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsLocalizationVO;
	import poliroid.gui.lobby.modsSettings.shared.Constants;

	public class ModsSettingsWindowHeader extends UIComponentEx
	{
		public var titleTF:TextField;
		public var closeButton:CloseButtonText;

		public function ModsSettingsWindowHeader()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			closeButton.addEventListener(ButtonEvent.CLICK, handleCloseButtonClick);
		}

		override protected function onDispose():void
		{
			closeButton.removeEventListener(ButtonEvent.CLICK, handleCloseButtonClick);
			closeButton.dispose();
			closeButton = null;
			titleTF = null;

			super.onDispose();
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			x = int((appWidth - Constants.MOD_COMPONENT_WIDTH) / 2);
			closeButton.x = Constants.MOD_COMPONENT_WIDTH - 56;
		}

		public function setLocalization(vo:ModsSettingsLocalizationVO):void
		{
			titleTF.text = vo.windowTitle;
			closeButton.label = vo.buttonClose;
		}

		private function handleCloseButtonClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.CLOSE_BUTTON_CLICK));
		}
	}
}
