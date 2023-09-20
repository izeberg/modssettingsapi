package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import scaleform.clik.constants.InvalidationType;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.gui.components.popovers.PopOverConst;
	import net.wg.gui.interfaces.ISoundButtonEx;
	
	import poliroid.gui.lobby.modsSettingsApi.controls.ColorChoisePopup;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;

	public class ColorChoiceButton extends SoundButtonEx implements ISoundButtonEx
	{
		public var hitAreaA:MovieClip;
		public var colorFill:MovieClip;

		private var _color:String;
		
		public function ColorChoiceButton()
		{
			super();
		}
		
		override protected function configUI() : void
		{
			preventAutosizing = true;

			super.configUI();
		}
		
		override protected function draw() : void
		{
			super.draw();

			if (isInvalid(InvalidationType.DATA))
			{
				colorFill.graphics.clear();
				colorFill.graphics.beginFill(parseInt(_color, 16));
				colorFill.graphics.drawRect(0, 0, 10, 10);
				colorFill.graphics.endFill();
			}
		}
		
		override protected function onMouseDownHandler(event:MouseEvent) : void
		{
			super.onMouseDownHandler(event);
			
			var popup:ColorChoisePopup = App.utils.classFactory.getComponent('ColorChoisePopupUI', ColorChoisePopup);
			popup.onValueChanged = onValueChanged;
			popup.color = color;
			popup.position = getPopupPosition(popup);
			popup.arrowDirection = getPopupArrowDirection();
			popup.showPopup();
		}
		
		private function getPopupArrowDirection() : int
		{
			var globalPos:Point = localToGlobal(new Point());
			var globalPosY:int = globalPos.y / App.appScale >> 0;
			var bottomOffset:int = globalPosY + Constants.MAX_BOTTOM_OFFSET;

			if (bottomOffset < App.appHeight)
			{
				return PopOverConst.ARROW_TOP;
			}

			return PopOverConst.ARROW_BOTTOM;
		}
		
		private function getPopupPosition(popup:ColorChoisePopup) : Point
		{
			var globalPos:Point = localToGlobal(new Point());
			var globalPosX:int = globalPos.x / App.appScale >> 0;
			var globalPosY:int = globalPos.y / App.appScale >> 0;
			var bottomOffset:int = globalPosY + Constants.MAX_BOTTOM_OFFSET;

			globalPosX += width >> 1;
			globalPosX -= popup.hitAreaA.width >> 1;
			globalPosX += 1;
			
			if (bottomOffset < App.appHeight)
			{
				globalPosY += height;
				globalPosY += 15;
			}
			else
			{
				globalPosY -= popup.hitAreaA.height;
				globalPosY -= height;
				globalPosY += 8;
			}

			return new Point(globalPosX, globalPosY);
		}
		
		public function onValueChanged(newColor:String) : void
		{
			color = newColor;
			dispatchEvent(new InteractiveEvent(InteractiveEvent.VALUE_CHANGED));
		}
		
		public function set color(newColor:String) : void
		{
			_color = newColor;
			invalidateData();
		}
		
		public function get color() : String
		{
			return _color;
		}
	}
}