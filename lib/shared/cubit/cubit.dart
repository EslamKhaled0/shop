import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/models/categories_model.dart';
import 'package:shop/models/change_favorites_model.dart';
import 'package:shop/models/favorites_model.dart';
import 'package:shop/models/home_model.dart';
import 'package:shop/models/login_model.dart';
import 'package:shop/modules/cateogries/categories_screen.dart';
import 'package:shop/modules/favorites/favorites_screen.dart';
import 'package:shop/modules/products/products_screen.dart';
import 'package:shop/modules/setting_screen/setting_screen.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/cubit/states.dart';
import 'package:shop/shared/network/end_points.dart';
import 'package:shop/shared/network/local/cache_helper.dart';
import 'package:shop/shared/network/remote/dio_helper.dart';


class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> bottomScreens = [
    ProductsScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void changeBottom(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel? homeModel;

  Map<int, bool> favorites = {};

  void getHomeData() {
    emit(ShopLoadingHomeDataState());

    DioHelper.getData(
      url: HOME,
      token: CacheHelper.getData(key: 'token'),
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);

      //print(homeModel.data.banners[0].image);
      //print(homeModel.status);

      homeModel!.data!.products.forEach((dynamic element) {
        favorites.addAll({
          element.id: element.inFavorites,
        });
      });

      //print(favorites.toString());

      emit(ShopSuccessHomeDataState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorHomeDataState());
    });
  }

  CategoriesModel? categoriesModel;

  void getCategories() {
    DioHelper.getData(
      url: GET_CATEGORIES,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);

      emit(ShopSuccessCategoriesState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorCategoriesState());
    });
  }

  ChangeFavoritesModel? changeFavoritesModel;

  void changeFavorites(int productId) {
    favorites[productId] = !favorites[productId]!;

    emit(ShopChangeFavoritesState());

    DioHelper.postData(
      url: FAVORITES,
      data: {
        'product_id': productId,
      },
      token: CacheHelper.getData(key: 'token'),
    ).then((value) {
      changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
      print(value.data);

      if (changeFavoritesModel!.status == false) {
        favorites[productId] = !favorites[productId]!;
      } else {
        getFavorites();
      }

      emit(ShopSuccessChangeFavoritesState(changeFavoritesModel!));
    }).catchError((error) {
      favorites[productId] = !favorites[productId]!;

      emit(ShopErrorChangeFavoritesState());
    });
  }

  FavoritesModel? favoritesModel;

  void getFavorites() {
    emit(ShopLoadingGetFavoritesState());

    DioHelper.getData(
      url: FAVORITES,
      token: CacheHelper.getData(key: 'token'),
    ).then((value) {
      favoritesModel = FavoritesModel.fromJson(value.data);
      //printFullText(value.data.toString());

      emit(ShopSuccessGetFavoritesState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorGetFavoritesState());
    });
  }

  ShopLoginModel? userModel;

  void getUserData() {
    emit(ShopLoadingUserDataState());

    DioHelper.getData(
      url: PROFILE,
      token: CacheHelper.getData(key: 'token'),
    ).then((value) {
      userModel = ShopLoginModel.fromJson(value.data);
      printFullText("${userModel!.data!.name}");

      emit(ShopSuccessUserDataState(userModel!));
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorUserDataState());
    });
  }

  void updateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());

    DioHelper.putData(
      url: UPDATE_PROFILE,
      token: CacheHelper.getData(key: 'token'),
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    ).then((value) {
      userModel = ShopLoginModel.fromJson(value.data);
      printFullText("${userModel!.data!.name}");

      emit(ShopSuccessUpdateUserState(userModel!));
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorUpdateUserState());
    });
  }
}