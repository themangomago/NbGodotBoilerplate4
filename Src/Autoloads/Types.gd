extends Node

enum InputDeviceType {Keyboard = 1, Mouse = 2, Joypad = 4, Touch = 8}

## Log level types
enum LogLevel {
	NONE = 0, ## No trace
	ERROR = 1, ## Trace errors
	WARNING = 2, ## Trace warnings
	INFO = 4, ## Trace info
	DEBUG = 8, ## Trace debug
}
