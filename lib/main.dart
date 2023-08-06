import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

showLoadingDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

enum TypeStatus { initial, loading, success, failure }

final class TypeState {
  final TypeStatus status;
  final String type;
  TypeState({
    this.status = TypeStatus.initial,
    this.type = '',
  });
}

class TypeCubit extends Cubit<TypeState> {
  TypeCubit() : super(TypeState());

  void checkType(int int) async {
    emit(TypeState(status: TypeStatus.loading));
    await Future.delayed(const Duration(seconds: 2));
    final type = int.isOdd ? 'Odd' : 'Even';
    emit(TypeState(status: TypeStatus.success, type: type));
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CounterCubit(),
        ),
        BlocProvider(
          create: (context) =>
              TypeCubit()..checkType(context.read<CounterCubit>().state),
        ),
      ],
      child: const MyHomePageView(),
    );
  }
}

class MyHomePageView extends StatelessWidget {
  const MyHomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc to Bloc communication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Number'),
            Text('${context.watch<CounterCubit>().state}'),
            const Text('Odd or Even?'),
            const SizedBox(
              height: 48,
              child: Center(child: CounterTypeText()),
            ),
            ElevatedButton(
                onPressed: context.watch<TypeCubit>().state.status ==
                        TypeStatus.success
                    ? () {
                        context.read<CounterCubit>().increment();
                      }
                    : null,
                child: const Text('Increment'))
          ],
        ),
      ),
    );
  }
}

class CounterTypeText extends StatelessWidget {
  const CounterTypeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, int>(
      listener: (context, state) {
        context.read<TypeCubit>().checkType(state);
      },
      child: BlocConsumer<TypeCubit, TypeState>(
        listener: (context, state) {
          // only show success not the other states
          print(state.status);
          if (state.status == TypeStatus.loading) {
            print('loading');
            showLoadingDialog(context);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case TypeStatus.initial:
              return Container();
            // it works but I want work with a loading dialog overlay instead
            // case TypeStatus.loading:
            //   return const Center(child: CircularProgressIndicator());
            case TypeStatus.failure:
              return const Center(child: Text('failed to get counter type'));
            case TypeStatus.success:
              // call this to close the dialog overlay
              // Navigator.pop(context);
              return Text(context.watch<TypeCubit>().state.type);
            default:
              return Container();
          }
        },
      ),
    );
  }
}
