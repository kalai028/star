import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_star/Models/repository_model.dart';
import 'package:git_star/Services/api_services.dart';
import 'package:git_star/Services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RepositoryNotifier extends StateNotifier<List<RepositoryModel>> {
  RepositoryNotifier() : super([]);

  //Indicates current page no & it will be incremented to + 1 each time the user reaches the bottom of the screen
  int currentPage = 0;
  //no. of repositories to get per api call (i.e 10 repository item we can get per api call or per page)
  int count = 10;
  //To get the repositories by its created date (i.e 60 days or 30 days ago)
  int daysAgo = 60;

  //Once no data exists, this will be become true.
  // And api call won't be done even if you reach reach bottom of the screen multiple times
  bool _finished = false;

  //To show loaders
  bool showLoader = true;

  //For storing errors
  String? error;

  Future<void> fetchData(context, {required bool hasInternet}) async {
    //Network Connection is enabled --> Fetch data from Server
    //Network Connection is disabled --> Fetch data from device (local database)
    if (hasInternet) {
      //Clearing existing data in local database after fetched latest data
      await DatabaseServices.deleteDb();
      //state is empty till the latest data to be fetched
      state = [];
      //fetching data from server
      await fetchDataFromServer(context);
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to the network'),
        ),
      );
      //Fetching data from sqlite...
      await fetchDataFromDevice();
      return;
    }
  }

  Future<void> fetchDataFromServer(context) async {
    String date = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: daysAgo)));

    if (_finished) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No more data'),
      ));
    } else {
      //Incrementing page number to avoid getting repeated data
      currentPage++;
      //Fetching data from server by its created date, how many items we want...
      try {
        final newItems = await ApiServices.fetchRepositories(http.Client(),
            date: date, count: count, pageNo: currentPage);

        if (newItems.length < count) {
          _finished = true;
        }
        //Storing the latest retrieved data on local database
        await DatabaseServices.storeRepositories(newItems);
        state = [...state, ...newItems];
        showLoader = false;
      } catch (e) {
        error = e.toString();
        state = [...state]; //To maintain the previous data or state
        showLoader = false;
      }
    }
  }

  Future<void> fetchDataFromDevice() async {
    try {
      final storedRepositories = await DatabaseServices.getRepositoriesList();
      state = [...storedRepositories];
      showLoader = false;
    } catch (e) {
      //
    }
  }

  String? get errorMessage => error;
}

final repositoryProvider =
    StateNotifierProvider<RepositoryNotifier, List<RepositoryModel>>(
        (ref) => RepositoryNotifier());
