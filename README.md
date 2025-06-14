# dynamic-control
A ESC/TCS control script for dynamic

# Add Database Table Column Headers.
ALTER TABLE player_vehicles
ADD COLUMN esc_enabled BOOLEAN DEFAULT FALSE,
ADD COLUMN tcs_enabled BOOLEAN DEFAULT FALSE;

# Add ensure to server.cfg
ensure dynamic_control
