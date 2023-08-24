import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snakegame/Direction.dart';
import 'package:snakegame/HomePage.dart';

class SnakGame extends StatefulWidget {
  const SnakGame({Key? key}) : super(key: key);

  @override
  _SnakGameState createState() => _SnakGameState();
}

class _SnakGameState extends State<SnakGame> {

  //时间
  int time = 0;
  //分数
  int number = 0;

  Timer ?_timer;
  //蛇一开始的位置
  List<Offset> snake = [Offset(5, 5),Offset(5, 4),Offset(5, 3),Offset(5, 2)];
  //食物一开始的位置
  Offset food = Offset(10, 10);
  //一开始的移动方向
  Direction direction = Direction.down;
  //游戏是否结束
  bool isGameOver = false;
  //蛇头位置
  Offset headPosition = Offset(5, 5);


  //时间第定时器每一秒加1
  void StartTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
       time++;
      });
    });
  }
  void startGame(){
    Timer.periodic(Duration(milliseconds: 250), (timer) {
      moveSnake();
      if (checkCollision()) {
        isGameOver = true;
        showGameOverDialog();
        return;
      }


      //snake.first检索第一个属性
      if(snake.first == food){
        generateFood();
        growSnake();
      }
      setState(() {});
    });
  }

  //移动方向
  void moveSnake(){
    //新的位置
    Offset newHead;
    switch (direction){
      case Direction.up:
        newHead = snake.first + Offset(0, -1);
        break;
      case Direction.down:
        newHead = snake.first + Offset(0, 1);
        break;
      case Direction.left:
        newHead = snake.first + Offset(-1, 0);
        break;
      case Direction.right:
        newHead = snake.first + Offset(1, 0);
        break;
    }
    //穿墙
    if (newHead.dx < 0) newHead = Offset(19, newHead.dy);
    if (newHead.dx > 19) newHead = Offset(0, newHead.dy);
    if (newHead.dy < 0) newHead = Offset(newHead.dx, 19);
    if (newHead.dy > 19) newHead = Offset(newHead.dx, 0);

    headPosition = newHead;
    //检索新的位置并且插入
    snake.insert(0, newHead);
    snake.removeLast();
  }

  bool checkCollision() {
    if (snake.first.dx < 0 ||
        snake.first.dx > 19 ||
        snake.first.dy < 0 ||
        snake.first.dy > 19) {
      return true;
    }

    for (int i = 1; i < snake.length; i++) {
      if (snake[i] == snake.first) {
        return true;
      }
    }

    return false;
  }

  //食物随机刷新位置
  void generateFood(){
    final random = Random();
    int x = random.nextInt(20);
    int y = random.nextInt(20);
    if(x <=20 ){
      setState(() {
        number++;
      });
    }
    food = Offset(x.toDouble(), y.toDouble());
  }

  //吃掉食尾部增长
  void growSnake(){
    Offset tail = snake.last;//最后位置
    Offset newTail;
    switch (direction) {
      case Direction.up:
        newTail = tail + Offset(0, 1);
        break;
      case Direction.down:
        newTail = tail + Offset(0, -1);
        break;
      case Direction.left:
        newTail = tail + Offset(1, 0);
        break;
      case Direction.right:
        newTail = tail + Offset(-1, 0);
        break;
    }

    snake.add(newTail);
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You hit yourself!'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                setState(() {
                  isGameOver = false;
                  snake = [Offset(5, 5),Offset(5, 4),Offset(5, 3),Offset(5, 2)];
                  direction = Direction.right;
                  food = Offset(10, 10);
                  time = 0;
                  number = 0;
                  Navigator.of(context).pop(); // Close the dialog
                  startGame();
                });
              },
            ),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
            }, child: Text("Back to home"))
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    StartTimer();
    startGame();
  }
  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("贪吃蛇"),),
      body: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height - 140,
              decoration:BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey
                ),
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (details){
                  if(direction != Direction.up && details.delta.dy > 0){
                    direction = Direction.down;
                    print(details.delta.dy);
                  }else if(direction != Direction.down && details.delta.dy < 0){
                    direction =Direction.up;
                    print(details.delta.dy);
                  }
                },
                onHorizontalDragUpdate: (details){
                  if(direction != Direction.left && details.delta.dx > 0){
                    direction = Direction.right;
                    print(details.delta.dx);
                  }else if(direction != Direction.right && details.delta.dx < 0){
                    direction = Direction.left;
                    print(details.delta.dx);
                  }
                },
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 20),
                    itemCount: 400,
                    itemBuilder: (context, index) {
                      Offset position = Offset(index % 20, (index ~/ 20).toDouble());
                      if(snake.contains(position)){
                        return Container(
                          color: position == headPosition ? Colors.black : Colors.green,
                        );
                      }else if(food == position){
                        return Container(
                          color: Colors.red,
                        );
                      }else{
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2 - 20,
              height: MediaQuery.of(context).size.height,
              child:Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      border:Border.all(width: 1,color: Colors.grey)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Duration：${time}",style:TextStyle(fontSize: 16,color: Colors.red),),
                        Text("Score：${number}",style:TextStyle(fontSize: 16,color: Colors.red),),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
