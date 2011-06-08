//  
//  Copyright (C) 2011 Maxwell Barvian
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Gtk;
using Gdk;
using Cairo;

namespace Maya.Widgets {

	public class DateSwitcher : Gtk.EventBox {  
	
		// Signals
		public signal void left_clicked ();
		public signal void right_clicked ();
		
		// Constants
		protected const int PADDING = 5;

		private bool _is_pressed = false;
		protected bool is_pressed {
			get { return _is_pressed; }
			set {
				_is_pressed = value;
				if (hovered == 0 || hovered == 2)
					box.get_children ().nth_data (hovered).set_state (value ? StateType.SELECTED : StateType.NORMAL);
				queue_draw ();
			}
		}
		
		private int _hovered = -1;
		protected int hovered {
			get { return _hovered; }
			set {
				_hovered = value;
				queue_draw ();
			}
		}
		
		private HBox box;
		
		private Label _label;
		public string label {
			get { return _label.label; }
			set { _label.label = value; }
		}

		public DateSwitcher () {
		
			// EventBox properties
			events |= EventMask.POINTER_MOTION_MASK
				   |  EventMask.BUTTON_PRESS_MASK
				   |  EventMask.BUTTON_RELEASE_MASK
				   |  EventMask.SCROLL_MASK
				   |  EventMask.LEAVE_NOTIFY_MASK;
			set_visible_window (false);

			// Initialize everything
			box = new HBox (false, 1);
			box.border_width = 0;
			_label = new Label ("");
			
			// Add everything in appropriate order
			box.pack_start (Utilities.set_paddings (new Arrow (ArrowType.LEFT, ShadowType.NONE), 0, PADDING, 0, PADDING),
					true, true, 0);
			box.pack_start (_label, true, true, PADDING);
			box.pack_start (Utilities.set_paddings (new Arrow (ArrowType.RIGHT, ShadowType.NONE), 0, PADDING, 0, PADDING),
					true, true, 0);
			
			add (box);
		}

		protected override bool scroll_event (EventScroll event) {
		
			switch (event.direction) {
				case ScrollDirection.LEFT:
					left_clicked ();
					break;
				case ScrollDirection.RIGHT:
					right_clicked ();
					break;
			}

			return true;	
		}

		protected override bool button_press_event (EventButton event) {
		
			is_pressed = (hovered == 0 || hovered == 2);

			return true;
		}
		
		protected override bool button_release_event (EventButton event) {
		
			is_pressed = false;
			if (hovered == 0)
				left_clicked ();
			else if (hovered == 2)
				right_clicked ();

			return true;
		}
		
		protected override bool motion_notify_event (EventMotion event) {
		
			Allocation box_size, left_size, right_size;
			box.get_allocation (out box_size);
			box.get_children ().nth_data (0).get_allocation (out left_size);
			box.get_children ().nth_data (2).get_allocation (out right_size);
			
			double x = event.x + box_size.x;

			if (x > left_size.x && x < left_size.x + left_size.width)
				hovered = 0;
			else if (x > right_size.x && x < right_size.x + right_size.width)
				hovered = 2;
			else
				hovered = -1;

			return true;
		}

		protected override bool leave_notify_event (EventCrossing event) {
		
			is_pressed = false;
			hovered = -1;

			return true;
		}

		protected override bool draw (Context cr) {
		
			Allocation box_size;
			box.get_allocation (out box_size);
			
			style.draw_box (cr, StateType.NORMAL, ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);
			
			if (hovered == 0 || hovered == 2) {

				Allocation arrow_size;
				box.get_children ().nth_data (hovered).get_allocation (out arrow_size);
				
				cr.rectangle (arrow_size.x - box_size.x, 0, arrow_size.width, arrow_size.height);
				cr.clip ();
				
				if (is_pressed)
					style.draw_box (cr, StateType.SELECTED, ShadowType.IN, this, "button", 0, 0, box_size.width, box_size.height);
				else
					style.draw_box (cr, StateType.PRELIGHT, ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);
							
				cr.restore ();
			}
			
			propagate_draw (box, cr);
			
			return true;
		}
		
	}
	
}
