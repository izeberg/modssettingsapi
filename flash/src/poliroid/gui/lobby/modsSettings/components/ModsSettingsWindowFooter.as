package poliroid.gui.lobby.modsSettings.components
{
	import scaleform.clik.events.ButtonEvent;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.infrastructure.base.UIComponentEx;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsLocalizationVO;
	import poliroid.gui.lobby.modsSettings.utils.Constants;

	public class ModsSettingsWindowFooter extends UIComponentEx
	{
		public var okButton:SoundButtonEx;
		public var cancelButton:SoundButtonEx;
		public var applyButton:SoundButtonEx;

		public function ModsSettingsWindowFooter()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			okButton.addEventListener(ButtonEvent.CLICK, handleOkButtonClick);
			cancelButton.addEventListener(ButtonEvent.CLICK, handleCancelButtonClick);
			applyButton.addEventListener(ButtonEvent.CLICK, handleApplyButtonClick);
			applyButton.enabled = false;
		}

		override protected function onDispose():void
		{
			okButton.removeEventListener(ButtonEvent.CLICK, handleOkButtonClick);
			cancelButton.removeEventListener(ButtonEvent.CLICK, handleCancelButtonClick);
			applyButton.removeEventListener(ButtonEvent.CLICK, handleApplyButtonClick);
			okButton.dispose();
			cancelButton.dispose();
			applyButton.dispose();
			okButton = null;
			cancelButton = null;
			applyButton = null;

			super.onDispose();
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			x = int((appWidth - Constants.MOD_COMPONENT_WIDTH) / 2);
			y = int(appHeight - 100);

			okButton.x = Constants.MOD_COMPONENT_WIDTH - 483;
			cancelButton.x = okButton.x + 170;
			applyButton.x = cancelButton.x + 170;
		}

		public function setLocalization(vo:ModsSettingsLocalizationVO):void
		{
			okButton.label = vo.buttonOK;
			cancelButton.label = vo.buttonCancel;
			applyButton.label = vo.buttonApply;
		}

		private function handleOkButtonClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.OK_BUTTON_CLICK));
		}

		private function handleCancelButtonClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.CANCEL_BUTTON_CLICK));
		}

		private function handleApplyButtonClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.APPLY_BUTTON_CLICK));
		}
	}
}
