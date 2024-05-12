package poliroid.gui.lobby.modsSettings.components
{
	import scaleform.clik.events.ButtonEvent;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.infrastructure.base.UIComponentEx;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsStaticVO;
	import poliroid.gui.lobby.modsSettings.utils.Constants;

	public class ModsSettingsWindowFooter extends UIComponentEx
	{
		public var buttonOK:SoundButtonEx;
		public var buttonCancel:SoundButtonEx;
		public var buttonApply:SoundButtonEx;

		public function ModsSettingsWindowFooter()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			buttonOK.addEventListener(ButtonEvent.CLICK, handleButtonOKClick);
			buttonCancel.addEventListener(ButtonEvent.CLICK, handleButtonCancelClick);
			buttonApply.addEventListener(ButtonEvent.CLICK, handleButtonApplyClick);
			buttonApply.enabled = false;
		}

		override protected function onDispose():void
		{
			buttonOK.removeEventListener(ButtonEvent.CLICK, handleButtonOKClick);
			buttonCancel.removeEventListener(ButtonEvent.CLICK, handleButtonCancelClick);
			buttonApply.removeEventListener(ButtonEvent.CLICK, handleButtonApplyClick);
			buttonOK.dispose();
			buttonCancel.dispose();
			buttonApply.dispose();
			buttonOK = null;
			buttonCancel = null;
			buttonApply = null;

			super.onDispose();
		}

		public function updateStaticData(model:ModsSettingsStaticVO):void
		{
			buttonOK.label = model.buttonOK;
			buttonCancel.label = model.buttonCancel;
			buttonApply.label = model.buttonApply;
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			x = int((appWidth - Constants.MOD_COMPONENT_WIDTH) / 2);
			y = int(appHeight - 100);

			buttonOK.x = Constants.MOD_COMPONENT_WIDTH - 483;
			buttonCancel.x = buttonOK.x + 170;
			buttonApply.x = buttonCancel.x + 170;
		}

		private function handleButtonOKClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_OK_CLICK));
		}

		private function handleButtonCancelClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CANCEL_CLICK));
		}

		private function handleButtonApplyClick(event:ButtonEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_APPLY_CLICK));
		}
	}
}
