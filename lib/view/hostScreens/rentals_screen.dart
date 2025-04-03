import 'package:flutter/material.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/view/widgets/posting_list_tile_ui.dart';

import '../widgets/calendar_ui.dart';


class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen>
{
  List<DateTime> _bookedDates = [];
  List<DateTime> _allBookedDates = [];
  PostingModel? _selectedPosting;

  List<DateTime> _getSelectedDates()
  {
    return [];
  }

  void _selectDate(DateTime date)
  {

  }

  void _selectAPosting(PostingModel posting)
  {
    _selectedPosting = posting;

    _bookedDates = posting.getAllBookedDates();

    setState(() {});
  }


  _clearSelectedPosting()
  {
    _selectedPosting = null;
    _bookedDates = _allBookedDates;

    setState(() {});
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bookedDates = AppConstants.currentUser.getAllBookedDates();
    _allBookedDates = AppConstants.currentUser.getAllBookedDates();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Sun"),
                  Text("Mon"),
                  Text("Tue"),
                  Text("Wed"),
                  Text("Thu"),
                  Text("Fri"),
                  Text("Sat"),
                ],
              ),
      
              //calendar
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 35),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: PageView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index)
                    {
                      return CalendarUi(
                        monthIndex: index,
                        bookedDates: _bookedDates,
                        selectDate: _selectDate,
                        getSelectedDates: _getSelectedDates,
                      );
                    }
                  ),
                ),
      
              ),
      
              //reset
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 0, 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
      
                    const Text(
                      "Filter by listing",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
      
                    MaterialButton(
                      onPressed: ()
                      {
                        _clearSelectedPosting();
      
                      },
                      child: const Text(
                          'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
      
                      Padding(
                        padding: const EdgeInsets.only(top: 25, bottom: 25),
                        child: Container(
      
                        ),
      
                      )
                  ],
      
                )
      
              ),
      
      
              //display host listings
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppConstants.currentUser.myPostings!.length,
                itemBuilder: (context, index)
                {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 26.0),
                    child: InkResponse(
                      onTap: ()
                      {
                        _selectAPosting(AppConstants.currentUser.myPostings![index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedPosting == AppConstants.currentUser.myPostings![index] ? Colors.blue : Colors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: PostingListTileUi(
                          posting: AppConstants.currentUser.myPostings![index],
                        ),
                      ),
                    ),
                  );
      
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
