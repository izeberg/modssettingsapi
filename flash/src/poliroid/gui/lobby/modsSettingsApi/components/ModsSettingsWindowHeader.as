package poliroid.gui.lobby.modsSettingsApi.components
{
	import flash.text.TextField;
	import scaleform.clik.events.ButtonEvent;
	import net.wg.gui.components.controls.CloseButtonText;
	import net.wg.infrastructure.base.UIComponentEx;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettingsApi.data.ModsSettingsStaticVO;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;

	public class ModsSettingsWindowHeader extends UIComponentEx
	{
		public var titleTF:TextField;
		public var buttonClose:CloseButtonText;

		public function ModsSettingsWindowHeader()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			buttonClose.addEventListener(ButtonEvent.CLICK, handlebuttonCloseClick);
		}

		override protected function onDispose():void
		{
			buttonClose.removeEventListener(ButtonEvent.CLICK, handlebuttonCloseClick);
			buttonClose.dispose();
			buttonClose = null;
			titleTF = null;

			super.onDispose();
		}

		public function updateStaticData(model:ModsSettingsStaticVO):void
		{
			titleTF.text = model.windowTitle;
			buttonClose.label = model.buttonClose;
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			x = int((appWidth - Constants.MOD_COMPONENT_WIDTH) / 2);
			buttonClose.x = Constants.MOD_COMPONENT_WIDTH - 56;
		}

		private function handlebuttonCloseClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLOSE_CLICK));
		}
	}
}
