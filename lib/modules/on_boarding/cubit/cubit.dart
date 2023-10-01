import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/models/on_boarding_model.dart';
import 'package:shop/modules/login/shop_login_screen.dart';
import 'package:shop/modules/on_boarding/cubit/states.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/network/local/cache_helper.dart';

class OnBoardingCubit extends Cubit<OnBoardingStates> {
  OnBoardingCubit() : super(OnBoardingInitialState());

  static OnBoardingCubit get(context) => BlocProvider.of(context);

  List<BoardingModel> boarding = [
    BoardingModel(
      title: 'easy',
      image: 'assets/on_boarding_assets/6859183.jpg',
      body: 'enjoy with flexible ui and easy to use',
    ),
    BoardingModel(
      title: 'discounts',
      image: 'assets/on_boarding_assets/6859183.jpg',
      body: 'enjoy with discounts',
    ),
    BoardingModel(
      title: 'favorites',
      image: 'assets/on_boarding_assets/6859183.jpg',
      body: 'add item to your favorites list',
    ),
  ];

  bool isLastBoarding = false;

  void changeIsLastBoarding(index){

    if (index == boarding.length - 1) {
      isLastBoarding = true;
    } else {
      isLastBoarding = false;
    }
    emit(OnBoardingChangeIsLastBoardingState());
  }


  void makeLoginFirstPage(context){

    CacheHelper.saveData(
      key: 'onBoarding',
      value: true,
    ).then((value)
    {
      if (value == true) {
        navigateAndFinish(
          context,
          ShopLoginScreen(),
        );
      }
    });
  }
}
