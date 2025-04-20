import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/db_connect.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

  @override
HomeScreenState createState()=> HomeScreenState(); 
}

class HomeScreenState extends State<HomeScreen> {

  var db = DbConnect();

  /*final List<Question> _questions = [
    Question(id: '10', title: '¿Que lenguaje se usa para programar Apps en Flutter?', options: {'Kotlin':false,'C#':false,'Dart':true,'Php':false}),

    Question(id: '11', title: '¿Cuanto es 10+20?', options: {'50':false,'30':true,'40':false,'10':false}),

    Question(id: '12', title: '¿Cual es una base de datos en la nube?', options: {'MariaDB':false,'NySQL':false,'Laragon':false,'Firebase':true})
  ];*/

  late Future _questions;

  Future<List<Question>> getData() async{
    return db.fetchQuestions();
  }

  @override
  void initState(){
    _questions = getData();
    super.initState();
  }



 int index = 0;

 bool isPressed = false;

 int score = 0;

 bool isAlreadySelected = false;

 void nextQuestion(questionLenght){
  if(index == questionLenght -1){
    showDialog(context: context, barrierDismissible: false ,builder: (ctx) => ResultBox(result: score,questionLeght: questionLenght,onPressed: startOver,));
  }else{
    if(isPressed){
    setState(() {
    index++;
    isPressed = false;
    isAlreadySelected = false;
    });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione una opcion'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(vertical: 20.0),)
      );
    }
   }
 }

 void checkAnswerAndUpdate(bool value){
  if(isAlreadySelected){
    return;
  }else{
    if( value == true){
    score++;
   }
   setState(() {
    isPressed = true;
    isAlreadySelected = true;
  });
  }
 }

 void startOver(){
  setState(() {
    index = 0;
    score = 0;
    isPressed = false;
    isAlreadySelected = false;
  });
  Navigator.pop(context);
 }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _questions as Future<List<Question>>,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError){
            return Center(child: Text('${snapshot.error}'),);
          }else if(snapshot.hasData){
            var extracteData = snapshot.data as List<Question>;
            return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('Quiz App'),
          backgroundColor: background,
          shadowColor: Colors.transparent,
          actions: [
            Padding(padding: const EdgeInsets.all(18.0),child: Text('Score: $score',
            style: const TextStyle(fontSize: 18.0),
            ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              QuestionWidget(indexAction:index,
              question: extracteData[index].title,
              totalQuestions: extracteData.length,
              ),
              const Divider(color: neutral),
              const SizedBox(height: 25.0),
              for(int i=0; i< extracteData[index].options.length; i++)
              GestureDetector(
                onTap: () => checkAnswerAndUpdate(extracteData[index].options.values.toList()[i]),
                child: OptionCard(option: extracteData[index].options.keys.toList()[i],
                color: isPressed ? extracteData[index].options.values.toList()[i] == true ? correct : incorrect : neutral,
                ),
              ),
            ],
          ),
        ),
      
        floatingActionButton: GestureDetector(
          onTap: () => nextQuestion(extracteData.length),
          child: const Padding(
            padding:  EdgeInsets.symmetric(horizontal: 10.0),
            child: NextButton(
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
          }
        }
        else{
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const CircularProgressIndicator(), //Se agrego const aqui y en sizedbox
              const SizedBox(height: 20.0),
              Text('Espere mientras las preguntas cargan...', style: TextStyle(color: Theme.of(context).primaryColor, decoration: TextDecoration.none, fontSize: 14.0),
              ),
            ],
          ),
          );
        }
        return const Center(child: Text('No Data'),
        );
      },
    );
  }
}