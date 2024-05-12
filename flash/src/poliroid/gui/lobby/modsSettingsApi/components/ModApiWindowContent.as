package poliroid.gui.lobby.modsSettingsApi.components
{
	import flash.display.MovieClip;
	import net.wg.infrastructure.base.UIComponentEx;
	import net.wg.gui.components.controls.ScrollPane;
	import net.wg.gui.components.controls.ScrollBar;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;

	public class ModApiWindowContent extends UIComponentEx
	{
		public var scrollPane:ScrollPane;
		public var scrollBar:ScrollBar;
		public var container:MovieClip;
		public var background:MovieClip;

		public function ModApiWindowContent()
		{
			super();

			container = new MovieClip();
		}

		override protected function configUI():void
		{
			super.configUI();

			scrollPane.scrollStepFactor = 20;
			scrollPane.scrollBar = scrollBar;
			scrollPane.isScrollBarHaveToBeShown = true;
			scrollPane.target = container;
		}

		override protected function onDispose():void
		{
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
	}
}
