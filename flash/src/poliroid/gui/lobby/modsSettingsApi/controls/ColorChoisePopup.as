package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import net.wg.gui.components.assets.GlowArrowAsset;
	import net.wg.gui.components.controls.Slider;
	import net.wg.gui.components.controls.TextInput;
	import net.wg.gui.components.controls.SoundButton;
	import net.wg.gui.components.popovers.PopOverConst;
	import net.wg.infrastructure.base.UIComponentEx;
	
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;
	
	public class ColorChoisePopup extends UIComponentEx
	{
		public var hitAreaA:MovieClip;
		public var background:MovieClip;
		public var arrowBottom:GlowArrowAsset;
		public var arrowTop:GlowArrowAsset;
		
		public var colorLabel:TextField;
		
		public var redSlider:Slider;
		public var greenSlider:Slider;
		public var blueSLider:Slider;
		
		public var hexTextInput:TextInput;
		public var colorSpectrum:MovieClip;
		public var colorPreview:MovieClip;
		public var acceptButton:SoundButton;
		
		private var _onValueChanged:Function;
		private var _color:String;
		private var _position:Point;
		private var _spectrumData:BitmapData;
		
		public function ColorChoisePopup()
		{
			super();
		}
		
		override protected function configUI() : void
		{
			super.configUI();
			
			_spectrumData = new BitmapData(colorSpectrum.width, colorSpectrum.height);
			_spectrumData.draw(colorSpectrum);
			
			hitArea = hitAreaA;
			
			arrowBottom.buttonMode = false;
			arrowBottom.mouseChildren = false;
			arrowBottom.mouseEnabled = false;

			arrowTop.buttonMode = false;
			arrowTop.mouseChildren = false;
			arrowTop.mouseEnabled = false;

			background.buttonMode = false;
			background.mouseChildren = false;
			background.mouseEnabled = false;
			background.width = hitAreaA.width + 120;
			background.height = hitAreaA.height + 120;
			 
			hexTextInput.maxChars = 7;
			hexTextInput.textField.restrict = "#A-F0-9";
			
			colorLabel.text = STRINGS.POPUP_COLOR;
			
			acceptButton.label = STRINGS.BUTTON_APPLY;
			
			App.stage.addEventListener(MouseEvent.MOUSE_DOWN, onAppMouseHandler);
			App.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onAppMouseHandler);
			App.stage.addEventListener(Event.RESIZE, handleClose);

			redSlider.addEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			greenSlider.addEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			blueSLider.addEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			acceptButton.addEventListener(ButtonEvent.PRESS, handleAccept);
			hexTextInput.addEventListener(InputEvent.INPUT, handleTextInput);
			colorSpectrum.addEventListener(MouseEvent.CLICK, handleSpectrumClick);
			
			addEventListener(InputEvent.INPUT, _handleInput);
			App.utils.focusHandler.setFocus(this);
		}
		
		override protected function onDispose() : void
		{
			App.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onAppMouseHandler);
			App.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onAppMouseHandler);
			App.stage.removeEventListener(Event.RESIZE, handleClose);
			removeEventListener(InputEvent.INPUT, _handleInput);

			redSlider.removeEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			greenSlider.removeEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			blueSLider.removeEventListener(SliderEvent.VALUE_CHANGE, handleSliders);
			acceptButton.removeEventListener(ButtonEvent.PRESS, handleAccept);
			hexTextInput.removeEventListener(InputEvent.INPUT, handleTextInput);
			colorSpectrum.removeEventListener(MouseEvent.CLICK, handleSpectrumClick);
			
			hitArea = null;
			
			super.onDispose();
		}
		
		override protected function draw() : void
		{
			super.draw();
			if (isInvalid(InvalidationType.DATA))
			{
				var colorHex:uint = parseInt(color, 16);
				var colorRgb:Object = {
					red: ((colorHex & 0xFF0000) >> 16),
					green: ((colorHex & 0x00FF00) >> 8),
					blue: ((colorHex & 0x0000FF))
				}
				
				colorPreview.graphics.clear();
				colorPreview.graphics.beginFill(colorHex);
				colorPreview.graphics.drawRect(0, 0, 100, 100);
				colorPreview.graphics.endFill();
				
				redSlider.value = colorRgb.red;
				greenSlider.value = colorRgb.green;
				blueSLider.value = colorRgb.blue;
				
				if (!hexTextInput.focused)
				{
					hexTextInput.text = "#" + color.toUpperCase();
				}
			}
		}
		
		private function handleSliders(e:SliderEvent) : void
		{
			var hexVal = (redSlider.value << 16 | greenSlider.value << 8 | blueSLider.value).toString(16); 
			while(hexVal.length < 6)
			{
				hexVal = "0" + hexVal;
			}
			color = hexVal;
		}
		
		private function handleTextInput(e:InputEvent) : void
		{
			if (hexTextInput.focused)
			{
				var newColor:String = hexTextInput.text;
				newColor = newColor.split('#').join('');
				if (newColor.length == 6)
				{
					color = newColor;
				}
			}
		}
		
		private function handleAccept(e:ButtonEvent) : void
		{
			if (_onValueChanged != null)
			{
				_onValueChanged(_color);
				handleClose();
			}
		}
		
		private function handleSpectrumClick(event:MouseEvent) : void
		{
			color = _spectrumData.getPixel(event.localX, event.localY).toString(16);
		}
		
		private function handleClose() : void
		{
			dispose();
		}
		
		private function onAppMouseHandler(param1:MouseEvent) : void
		{
			if(!hitAreaA.hitTestPoint(App.stage.mouseX, App.stage.mouseY))
			{
				handleClose();
			}
		}
		
		public function showPopup() : void
		{
			App.utils.popupMgr.removeAll();
			App.utils.popupMgr.show(DisplayObject(this), _position.x, _position.y);
		}
		
		public function set onValueChanged(callback:Function) : void
		{
			_onValueChanged = callback;
		}
		
		public function set color(newColor:String) : void
		{
			if (newColor == _color)
			{
				return;
			}
			_color = newColor;
			invalidateData();
		}
		
		public function get color() : String
		{
			return _color;
		}
		
		public function set position(position:Point) : void
		{
			_position = position;
		}
		
		public function get position() : Point
		{
			return _position;
		}
		
		public function set arrowDirection(direction:int) : void
		{
			arrowBottom.visible = false;
			arrowTop.visible = false;
			if (direction == PopOverConst.ARROW_BOTTOM)
			{
				arrowBottom.visible = true;
			}
			else
			{
				arrowTop.visible = true;
			}
		}

		private function _handleInput(event:InputEvent) : void
		{
			var details:InputDetails = event.details;
			if(details.code == Keyboard.ESCAPE)
			{
				event.handled = true;
				event.preventDefault();
				if (details.value == InputValue.KEY_DOWN)
				{
					App.popoverMgr.hide();
					dispose();
				}
			}
		}
	}
}
