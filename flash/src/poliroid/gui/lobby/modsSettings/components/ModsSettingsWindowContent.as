package poliroid.gui.lobby.modsSettings.components
{
	import flash.display.MovieClip;
	import net.wg.infrastructure.base.UIComponentEx;
	import net.wg.gui.components.controls.ScrollBar;
	import net.wg.gui.components.controls.ScrollPane;
	import net.wg.gui.components.controls.events.ScrollPaneEvent;
	import poliroid.gui.lobby.modsSettings.utils.Constants;

	public class ModsSettingsWindowContent extends UIComponentEx
	{
		public var scrollPane:ScrollPane;
		public var scrollBar:ScrollBar;
		public var container:MovieClip;
		public var background:MovieClip;

		public function ModsSettingsWindowContent()
		{
			super();

			container = new MovieClip();
		}

		override protected function configUI():void
		{
			super.configUI();

			scrollPane.scrollBar = scrollBar;
			scrollPane.target = container;
			scrollPane.scrollStepFactor = 100;
			scrollPane.addEventListener(ScrollPaneEvent.POSITION_CHANGED, handleScrollPanePositionChange);
		}

		override protected function onDispose():void
		{
			scrollPane.removeEventListener(ScrollPaneEvent.POSITION_CHANGED, handleScrollPanePositionChange);
			scrollPane.dispose();
			scrollBar.dispose();
			scrollPane = null;
			scrollBar = null;
			container = null;

			super.onDispose();
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			scrollPane.setSize(Constants.MOD_COMPONENT_WIDTH, appHeight - 200);

			x = int((appWidth - Constants.MOD_COMPONENT_WIDTH) / 2);
			y = 100;

			scrollBar.height = int(appHeight - 204);
			scrollBar.x = Constants.MOD_COMPONENT_WIDTH;

			background.width = Constants.MOD_COMPONENT_WIDTH + 200;
			background.height = int(appHeight - 200);
		}

		private function handleScrollPanePositionChange(event:ScrollPaneEvent):void
		{
			App.utils.scheduler.scheduleOnNextFrame(function():void {
				container.y = int(container.y);
			});
		}
	}
}
