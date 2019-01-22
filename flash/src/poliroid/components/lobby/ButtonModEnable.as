package poliroid.components.lobby
{
	
	import poliroid.lang.STRINGS;
	import poliroid.lang.*;
	import flash.display.*;
	import flash.events.*;
	import net.wg.gui.components.controls.SoundButton;
	import scaleform.clik.core.UIComponent;
	
	public class ButtonModEnable extends SoundButton
	{
		[Embed(source="../../../../res/modsSettingsApi/buttonNormal.png")]
		private static var buttonNormalImage:Class;
		[Embed(source="../../../../res/modsSettingsApi/buttonHover.png")]
		private static var buttonHoverImage:Class;
		[Embed(source="../../../../res/modsSettingsApi/buttonPressed.png")]
		private static var buttonPressedImage:Class;
		[Embed(source="../../../../res/modsSettingsApi/buttonIconOn.png")]
		private static var buttonIconOnImage:Class;
		[Embed(source="../../../../res/modsSettingsApi/buttonIconOff.png")]
		private static var buttonIconOffImage:Class;
		
		private var button_normal:Bitmap;
		private var button_hover:Bitmap;
		private var button_pressed:Bitmap;
		private var button_icon_on:Bitmap;
		private var button_icon_off:Bitmap;
		
		public var _tolltip:String;
		
		private var _enabled:Boolean = false;
		
		
		public function ButtonModEnable()
		{
			super();
			
			
			this.width = 25;
			this.height = 25;
			
			
			this.button_normal = new buttonNormalImage();
			this.addChild(this.button_normal);
			
			this.button_hover = new buttonHoverImage();
			this.button_hover.visible = false;
			this.addChild(this.button_hover);
			
			this.button_pressed = new buttonPressedImage();
			this.button_pressed.visible = false;
			this.addChild(this.button_pressed);
			
			this.button_icon_off = new buttonIconOffImage();
			this.button_icon_off.visible = false;
			this.addChild(this.button_icon_off);
			
			this.button_icon_on = new buttonIconOnImage();
			this.button_icon_on.visible = false;
			this.addChild(this.button_icon_on);
			
			this.drawIcon();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUP);
		}
		
		public function set isEnabled(isEnabled:Boolean):void
		{
			this._enabled = isEnabled;
			this.drawIcon();
		}
		
		public function get isEnabled():Boolean
		{
			return this._enabled;
		}
		
		

		override protected function handleMouseRollOver(event:MouseEvent):void
		{
			this.button_hover.visible = true;
			this.button_pressed.visible = false;
			this.drawIcon();
			App.toolTipMgr.showComplex(STRINGS.BUTTON_ENABLED_TOOLTIP);
			super.handleMouseRollOut(event);
		}
		
		override protected function handleMouseRollOut(event:MouseEvent):void
		{
			this.button_hover.visible = false;
			this.button_pressed.visible = false;
			this.drawIcon();
			App.toolTipMgr.hide();
			super.handleMouseRollOut(event);
		}
		
		private function handleMouseDown(event:MouseEvent):void {
			this.button_hover.visible = false;
			this.button_pressed.visible = true;
			this.button_icon_on.y = 1;
			this.button_icon_off.y = 1;
		}
		private function handleMouseUP(event:MouseEvent):void {
			this.button_hover.visible = true;
			this.button_pressed.visible = false;
			this.drawIcon();
		}
		
		private function drawIcon(): void {
			this.button_icon_on.y = 0;
			this.button_icon_off.y = 0;
			this.button_icon_on.visible = false;
			this.button_icon_off.visible = false;
			if (this.isEnabled) {this.button_icon_on.visible = true;} else {this.button_icon_off.visible = true;}
		}
	}

}
