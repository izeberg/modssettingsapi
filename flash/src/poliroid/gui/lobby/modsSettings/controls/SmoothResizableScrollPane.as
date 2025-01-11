
package poliroid.gui.lobby.modsSettings.controls
{
	import flash.events.Event;
	import flash.utils.getTimer;
	import scaleform.clik.constants.InvalidationType;
	import net.wg.gui.components.controls.events.ScrollBarEvent;
	import net.wg.gui.components.controls.events.ScrollPaneEvent;
	import net.wg.gui.components.controls.ResizableScrollPane;

	/**
	 * Class SmoothResizableScrollPane.
	 * Smooth Scroll target animation in ScrollPane control
	 */
	public class SmoothResizableScrollPane extends ResizableScrollPane
	{
		private var _smoothScrollPosition:Number = 0;
		private var _smoothScrollStepFactor:Number = 100;
		private var _smoothScrollDuration:Number = 1000;
		private var _restoreBottomPosition:Boolean = false;
		private var _scrollStartTime:Number = NaN;
		private var _scrollStartPosition:Number = NaN;
		private var _isScrolling:Boolean = false;
		private var _cachedMaxScroll:Number = NaN;

		protected static const SCROLL_STEEP_SIZE:int = 10;

		override protected function configUI():void
		{
			super.configUI();
			addEventListener(ScrollPaneEvent.POSITION_CHANGED, handlePositionChange);
		}

		private function handlePositionChange(event:ScrollPaneEvent):void
		{
			App.utils.scheduler.scheduleOnNextFrame(function():void {
				if (target.y != int(target.y))
					target.y = int(target.y);
			});
		}

		/**
		 * Update _smoothScrollPosition on manual scroll by scrollbar
		 */
		private function onScrollBarEndDrag(event:ScrollBarEvent):void
		{
			if (scrollBar)
				_smoothScrollPosition = int(scrollBar.position);
		}

		/**
		 * Subscribe for scrollbar ON_END_DRAG event
		 */
		override protected function draw():void
		{
			super.draw();
			if(scrollBar && isInvalid(InvalidationType.SCROLL_BAR))
				scrollBar.addEventListener(ScrollBarEvent.ON_END_DRAG, onScrollBarEndDrag);
		}

		/**
		 * Update scrollStep for scrollbar track click
		 */
		override protected function applyScrollBarUpdating():void
		{
			super.applyScrollBarUpdating();
			scrollBar.setScrollProperties(scrollPageSize, 0, maxScroll, _smoothScrollStepFactor);
		}

		/**
		 * Change scroll position to max bottom
		 * if it was previous state of scroll
		 */
		override protected function applyTargetChanges():void
		{
			super.applyTargetChanges();
			if (!_restoreBottomPosition)
				return;
			if (_smoothScrollPosition == _cachedMaxScroll)
				_smoothScrollPosition = scrollPosition = maxScroll;
			_cachedMaxScroll = maxScroll;
		}

		/**
		 * handle Mouse Wheel event
		 */
		override public function doMouseWheel(value:int):void
		{
			// calculate target scroll position
			var moveDelta = value > 0 ? _smoothScrollStepFactor : -_smoothScrollStepFactor;
			_smoothScrollPosition = Math.min(maxScroll, Math.max(0, smoothScrollPosition - moveDelta));
			_smoothScrollStart();
		}

		private function _smoothScrollStart():void
		{
			_scrollStartTime = getTimer();
			_scrollStartPosition = int(scrollPosition);
			if (!_isScrolling)
			{
				_isScrolling = true;
				_smoothScrollAnimation();
				App.stage.addEventListener(Event.ENTER_FRAME, _smoothScrollAnimation);
			}
		}

		private function _smoothScrollStop():void
		{
			if (scrollPosition == smoothScrollPosition && _isScrolling)
			{
				App.stage.removeEventListener(Event.ENTER_FRAME, _smoothScrollAnimation);
				_isScrolling = false;
			}
		}

		/**
		 * Smooth scroll animation logic
		 * animated with inverted easing out cubic
		 */
		private function _smoothScrollAnimation():void
		{
			var animationTime:Number = (getTimer() - _scrollStartTime) / _smoothScrollDuration;
			var k = animationTime - 1;
			var animationCoeff:Number = k * k * k + 1;
			animationCoeff = Math.min(1, animationCoeff);
			scrollPosition = _scrollStartPosition + int((smoothScrollPosition - _scrollStartPosition) * animationCoeff);
			_smoothScrollStop();
		}

		public function get smoothScrollDuration() : Number
		{
			return _smoothScrollDuration;
		}

		public function set smoothScrollDuration(value:Number):void
		{
			_smoothScrollDuration = value;
		}

		public function get smoothScrollPosition() : Number
		{
			return _smoothScrollPosition;
		}

		public function set smoothScrollPosition(value:Number):void
		{
			_smoothScrollPosition = value;
			scrollPosition = value;
		}

		public function get smoothScrollStepFactor() : Number
		{
			return _smoothScrollStepFactor;
		}

		public function set smoothScrollStepFactor(value:Number):void
		{
			_smoothScrollStepFactor = value;
		}

		public function get restoreBottomPosition() : Boolean
		{
			return _restoreBottomPosition;
		}

		public function set restoreBottomPosition(value:Boolean):void
		{
			_restoreBottomPosition = value;
		}
	}
}
