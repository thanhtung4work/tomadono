class Timer {
    static const String POMODORO = "pomodoro";
    static const String SHORT_BREAK = "shortBreak";
    static const String LONG_BREAK = "longBreak";

    var timer = {
        "pomodoro": 25,
        "shortBreak": 5,
        "longBreak": 15,
        "longBreakInterval": 4
    };

    int pomodoro = 25;
    int shortBreak = 5;
    int longBreak = 15;
    int longBreakInterval = 4;
    String mode = "pomodoro";
    Map<String, int> remainingTime = {"total": 25 * 60};

    int getModeTime(String mode){
        if(mode == "pomodoro") {
            return 25;
        }
        if(mode == "shortBreak") {
            return 5;
        }
        if(mode == "longBreak") {
            return 15;
        }
        return 0;
    }
}