require 'bundler/setup'
require 'dino'
# require 'stepper'

board = Dino::Board.new(Dino::TxRx::Serial.new)
ldr = Dino::Components::Sensor.new(pin: 0, board: board)
ldr_threshold = 800
temp = Dino::Components::Sensor.new(pin: 5, board: board)
temp_threshold = 72
temp_voltage = 5.00
led = Dino::Components::Led.new(pin: 13, board: board)

# Variables for storing curtain state—as well as the analog values of the photocell and temperature sensors two boolean variables, daylight and warm—are used in the main loop’s conditional statements to identify the status of daylight and the indoor room temperature. We also assign the number of steps per revolution (in this case, 100) and the motor shield port that the stepper motor is attached to (in this case, the second port per the wiring diagram) by creating an AF_Stepper object called motor.

curtain_state = 1
light_status = 0
temp_status = 0

daylight = true
warm = false

# Stepper
----------------

# stepper = Dino::Components::Stepper.new(board: board, pins: { step: 10, direction: 8 })

#   1600.times do
#     stepper.step_cc
#     sleep 0.001
#   end

#   1600.times do
#     stepper.step_cw
#     sleep 0.001
#   end
----------------

def initialize
	puts "Setting up curtain automation..."
end


loop {  
# The Curtain function will be called when the light or temperature thresholds are exceeded. The state of the curtains (open or closed) is maintained so that the motor doesn’t keep running every second the threshold is exceeded. After all, once the curtains are opened, there’s no need to open them again. In fact, doing so might even damage the stepper motor, grooved pulley, or curtain drawstring.
# If the Curtain function receives a curtain_state of true, the stepper motor will spin counterclockwise to open the curtains. A curtain_state value of false will spin clockwise to close the curtains.
# We will also use the Arduino’s onboard LED to indicate the status of the curtains. If the curtains are open, the LED will remain lit. Otherwise, the LED will be off. Since the motor shield will be covering the top of the Arduino, the onboard LED won’t be easily visible, but it will still serve as a good visual aid for debugging purposes.
---------------------------
def curtain(curtain_state)
	if curtain_state == 1 
		led.send(:on)
		puts "Opening curtain..."
		# stepper.step_cw
	else
		led.send(:off)
		puts "Closing curtain..."
		# stepper.step_cc
	end
end

# We poll the analog values of the photocell and temperature every second, convert the electrical value of the temperature sensor both to Celsius and—for those who have yet to convert to the metric system—Fahrenheit. If the light sensor exceeds the LIGHT_THRESHOLD value we assigned in the define section of the sketch, then it must be daytime (i.e., daytime = true). However, we don’t want to open the curtains if it’s already warm in the room, since the incoming sunlight would make the room even warmer. Thus, if the temperature status exceeds the TEMP_THRESHOLD, we will keep the curtains closed until the room cools down. After checking the status of the curtain_state, we will pass a new state to the Curtain routine and open or close the curtains accordingly.


# pull photosensor value
----------------------
ldr.when_data_recieved do |data|
	light_status = data
	sleep 0.5

	# print light_status value to serial port
	puts "Photocell value = #{light_status}"
end

# pull temperature
-------------------
temp.when_data_recieved do |data|
	temp_reading = data
	sleep 0.5
end

# convert voltage to temp in Celsius and Fahrenheit
---------------------------------------------------
voltage = temp_reading * temp_voltage / 1024.0
temp_celsius = (voltage - 0.5) * 100
temp_fahrenheit = (temp_celsius * 9 / 5) + 32

puts "Temperature value (Celsius) = #{temp_celsius}"
puts "Temperature value (Fahrenheit) = #{temp_fahrenheit}"

if light_status > ldr_threshold
	daylight = true
else
	daylight = false
end

if temp_fahrenheit > temp_threshold
	warm = true
else
	warm = false
end

case curtain_state
when 0
	if daylight && not(warm)
		curtain_state = 1         #open curtain
		Curtain(curtain_state)
	end
	break
when 1
	if not(daylight) || warm
		curtain_state = 0         #close curtain
		Curtain(curtain_state)
	end
	break	
end

}
