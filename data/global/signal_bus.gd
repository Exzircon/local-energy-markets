extends Node
##Simple SignalBus Global Node

## Signal emitted by buildings when they want their stats displayed in the bottom right
@warning_ignore("unused_signal")
signal display_stats(agent: Building)
