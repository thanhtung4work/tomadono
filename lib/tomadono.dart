import 'dart:async';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:tomadono/my_helper.dart';

class TomadonoApp extends StatelessWidget {
  const TomadonoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Tomadono",
        debugShowCheckedModeBanner: false,
        home: TomadonoHome(),
    );
  }
}

class TomadonoHome extends StatefulWidget {
  const TomadonoHome({Key? key}) : super(key: key);

  @override
  State<TomadonoHome> createState() => _TomadonoHomeState();
}

class _TomadonoHomeState extends State<TomadonoHome> {

    static const String POMODORO = "pomodoro";
    static const String SHORT_BREAK = "shortBreak";
    static const String LONG_BREAK = "longBreak";

    String mainButtonAction = "start";
    String focus = "time to focus";
    String message = "time to focus";
    String rest = "time to take a break";

    Color appBarColor = MyHelper.tomadonoAppBarColor;
    Color backgroundColor = MyHelper.tomadonoBackgroundColor;
    Color buttonsColor = MyHelper.tomadonoButtonColor;

    var timerDetails = {
        "pomodoro": 25,
        "shortBreak": 5,
        "longBreak": 15,
        "longBreakInterval": 4,
        "session": 0,
        "mode": "pomodoro",
        "remainingTime": {
            "total": 25 * 60,
            "minute": 25,
            "second": 0
        }
    };
    late Timer interval = Timer(const Duration(seconds: 1), () {});

    String minutes = "25";
    String seconds = "00";

    List<String> tasks = [];
    String currentTask = "your task";

    void switchColor(String mode) {
        setState(() {
            if(mode == POMODORO) {
                appBarColor = MyHelper.tomadonoAppBarColor;
                backgroundColor = MyHelper.tomadonoBackgroundColor;
                buttonsColor = MyHelper.tomadonoButtonColor;
            } else if(mode == SHORT_BREAK) {
                appBarColor = MyHelper.shortBreakAppBarColor;
                backgroundColor = MyHelper.shortBreakBackgroundColor;
                buttonsColor = MyHelper.shortBreakButtonColor;
            } else if(mode == LONG_BREAK) {
                appBarColor = MyHelper.longBreakAppBarColor;
                backgroundColor = MyHelper.longBreakBackgroundColor;
                buttonsColor = MyHelper.longBreakButtonColor;
            }
        });
    }

    void switchMode(String mode) {
        stopTimer();
        timerDetails["mode"] = mode;
        int time = (timerDetails[mode] ?? 0) as int;
        timerDetails["remainingTime"] = {
            "total": time * 60,
            "minute": timerDetails[mode],
            "second": 0
        };

        setState(() {
            if(mode == POMODORO) {
                message = focus;
            } else {
                message = rest;
            }
        });

        switchColor(mode);
        updateClock();
    }

    void updateClock() {
        Map remainingTime = timerDetails["remainingTime"] as Map;
        setState(() {
            minutes = "${remainingTime["minute"]}".padLeft(2, "0");
            seconds = "${remainingTime["second"]}".padLeft(2, "0");
        });
    }

    void startTimer() {
        Map remainingTime = timerDetails["remainingTime"] as Map;
        int total = remainingTime["total"];
        var endTime = DateTime.now().add(Duration(seconds: total));

        if (timerDetails["mode"] == POMODORO){
            timerDetails["session"] = (timerDetails["session"] as int) + 1;
        }

        setState((){mainButtonAction = "stop";});

        interval = Timer.periodic(const Duration(seconds: 1), (timer) {
            timerDetails["remainingTime"] = getRemainingTime(endTime);
            updateClock();

            Map remainingTime = timerDetails["remainingTime"] as Map;
            int total = remainingTime["total"];
            if (total <= 0) {
                interval.cancel();
                // audioPlayer.play();
                HapticFeedback.vibrate();

                switch(timerDetails["mode"]) {
                    case POMODORO:
                        int timerSession = timerDetails["session"] as int;
                        int longBreakInterval = timerDetails["longBreakInterval"] as int;

                        if (timerSession % longBreakInterval == 0) {
                            switchMode(LONG_BREAK);
                        } else {
                            switchMode(SHORT_BREAK);
                        }
                        break;
                    default:
                        switchMode(POMODORO);
                }
                startTimer();
            }
        });
    }

    void stopTimer() {
        interval.cancel();
        setState((){mainButtonAction = "start";});
    }

    Map<String, int> getRemainingTime (DateTime endTime) {
        DateTime currentTime = DateTime.now();
        Duration different = endTime.difference(currentTime);

        int total = different.inSeconds;
        int minute = different.inMinutes;
        int second = total % 60;

        return {
            "total": total,
            "minute": minute,
            "second": second
        };
    }

    @override
    void dispose() {
        // TODO: implement dispose
        super.dispose();
        // audioPlayer.dispose();
        taskController.dispose();
    }

    final taskController = TextEditingController();
    void showTaskDialog() {
        showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Enter task"),
                content: Padding(
                    padding: EdgeInsets.all(0),
                    child: Form(
                        child: TextFormField(
                            controller: taskController,
                            decoration: InputDecoration(labelText: "task's name", icon: Icon(Icons.edit)),
                        ),
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () {
                            Navigator.pop(context);
                            // print(taskController.text);
                            setState((){
                                tasks.add(taskController.text);
                            });
                        },
                        child: Text("ok"))
                ],
            );
        });
    }

    void showSettingDialog() {
        showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
                content: Container(
                    height: 50,
                    child: const Center(
                        child: Text("Made by Tran Thanh Tung and he likes milk tea"),
                    ),
                ),
                actions: [
                TextButton(
                    onPressed: () {
                        Navigator.pop(context);
                    },
                    child: const Text("ok"))
                ],
            );
        });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: appBarColor,
            title: Text("Tomadono"),
            actions: [
                IconButton(onPressed: () {showSettingDialog();}, icon: Icon(Icons.settings))
            ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Expanded(
                    flex: 3,
                    child: Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                      TomadonoButton(callback: (){switchMode(POMODORO);}, buttonText: "tomadono", buttonColor: buttonsColor),
                                      TomadonoButton(callback: (){switchMode(LONG_BREAK);}, buttonText: "long break", buttonColor: buttonsColor),
                                      TomadonoButton(callback: (){switchMode(SHORT_BREAK);}, buttonText: "short break", buttonColor: buttonsColor),
                                  ],
                                  ),
                                Text(
                                    "$message\n[$currentTask]",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                                ),
                                Text("$minutes:$seconds", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 80),),
                                ElevatedButton(
                                    onPressed: (){
                                        if (mainButtonAction == "start") {
                                          startTimer();
                                        } else {
                                          stopTimer();
                                        }
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.white),
                                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 20))
                                    ),
                                    child: Text(
                                        mainButtonAction,
                                        style: TextStyle(fontSize: 28, color: backgroundColor),
                                    )
                                )
                            ],
                        ),
                    ),
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: buttonsColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)
                            )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Expanded(
                                      flex: 1,
                                      child: Text("   my tasks", style: TextStyle(fontSize: 16, color: Colors.white),)
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: ListView.separated(
                                        separatorBuilder: (BuildContext context, int index) => const Divider(height: 2,),
                                        itemCount: tasks.length,
                                        itemBuilder: (BuildContext context, int index) {
                                            return Row(
                                                children: [
                                                    Expanded(
                                                        flex: 4,
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(backgroundColor),
                                                              foregroundColor: MaterialStateProperty.all(Colors.white)
                                                          ),
                                                          onPressed: (){
                                                              setState(() {
                                                                  currentTask = tasks[index];
                                                              });
                                                          },
                                                          child: Center(child: Text(tasks[index])),
                                                        ),
                                                    ),
                                                    Expanded(
                                                        flex:1,
                                                        child: IconButton(
                                                            icon: Icon(Icons.delete),
                                                            onPressed: () {
                                                                print("Remove at $index");
                                                                setState(() {
                                                                    tasks.removeAt(index);
                                                                });
                                                            },
                                                        )
                                                    )
                                                ],
                                            );
                                    } ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: TomadonoTaskButton(callback: () {showTaskDialog();}, buttonText: "+ add task +", buttonColor: buttonsColor,)
                                  )
                              ],
                          ),
                        ),
                    )
                )
            ],
        ),
    );
  }
}

class TomadonoButton extends StatelessWidget {

    VoidCallback callback;
    String buttonText;
    Color buttonColor;
    TomadonoButton({Key? key, required this.callback, required this.buttonText, required this.buttonColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all( buttonColor ),
        ),
        onPressed: callback,
        child: Text(buttonText, style: TextStyle(color: Colors.white),)
    );
  }
}

class TomadonoTaskButton extends StatelessWidget {

    VoidCallback callback;
    String buttonText;
    Color buttonColor;
    TomadonoTaskButton({Key? key, required this.callback, required this.buttonText, required this.buttonColor}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all( buttonColor ),
                  ),
                  onPressed: callback,
                  child: Text(buttonText, style: TextStyle(color: Colors.white),)
              ),
            ),
          ],
        );
    }
}