package poliroid.gui.lobby.modsSettings.components
{
	import flash.display.MovieClip;
	import net.wg.infrastructure.base.UIComponentEx;
	import net.wg.gui.components.controls.BitmapFill;
	import net.wg.gui.components.controls.UILoaderAlt;
	import net.wg.gui.events.UILoaderEvent;
	import poliroid.gui.lobby.modsSettings.shared.Constants;

	public class ModsSettingsWindowBackground extends UIComponentEx
	{
		public var bgLoader:UILoaderAlt;
		public var bgFill:BitmapFill;
		public var bgImage:MovieClip;

		private var _originalBgWidth:Number = 0;
		private var _originalBgHeight:Number = 0;

		public function ModsSettingsWindowBackground()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			bgLoader.addEventListener(UILoaderEvent.COMPLETE, onBgLoaderCompleteHandler);
			bgLoader.source = Constants.WINDOW_BACKGROUND_IMAGE;
		}

		override protected function onDispose():void
		{
			bgLoader.removeEventListener(UILoaderEvent.COMPLETE, onBgLoaderCompleteHandler);
			bgFill.dispose();
			bgLoader.dispose();
			bgFill = null;
			bgLoader = null;

			super.onDispose();
		}

		public function updateStage(appWidth:Number, appHeight:Number):void
		{
			bgFill.widthFill = appWidth;
			bgFill.heightFill = appHeight;

			bgImage.width = appWidth;
			bgImage.height = appHeight;

			if (_originalBgWidth != 0 && _originalBgHeight != 0)
			{
				bgLoader.scaleX = bgLoader.scaleY = Math.max(appWidth / _originalBgWidth, appHeight / _originalBgHeight);
				bgLoader.x = appWidth - bgLoader.width >> 1;
			}
		}

		private function onBgLoaderCompleteHandler(event:UILoaderEvent):void
		{
			_originalBgWidth = bgLoader.width;
			_originalBgHeight = bgLoader.height;

			var appWidth:Number = App.appWidth;
			var appHeight:Number = App.appHeight;

			updateStage(appWidth, appHeight);
		}
	}
}
