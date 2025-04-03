import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luti/global.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/view/host_home_screen.dart';
import 'package:luti/view/widgets/amenities_ui.dart';


class CreatePostingScreen extends StatefulWidget
{
  final PostingModel? posting;

  const CreatePostingScreen({super.key, this.posting,});

  @override
  State<CreatePostingScreen> createState() => _CreatePostingScreenState();
}

class _CreatePostingScreenState extends State<CreatePostingScreen>
{
  final formkey = GlobalKey<FormState>();
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _addressTextEditingController = TextEditingController();
  TextEditingController _cityTextEditingController = TextEditingController();
  TextEditingController _amenitiesTextEditingController = TextEditingController();

  final List<String> residenceTypes = [
    'Detached House',
    'Villa',
    'Apartment',
    'Condo',
    'Flat',
    'Town House',
    'Studio',
  ];

  String residenceTypeSelected = "";


  Map<String,int> _beds = {
    'small' : 0,
    'medium' : 0,
    'Large' : 0
  };
  Map<String,int> _bathrooms = {
    'small' : 0,
    'medium' : 0,
    'Large' : 0
  };
  Map<String,int> _kitchen = {
    'full' : 0,
    'half' : 0,
    'None' : 0
  };
  Map<String,int> _furniture = {
    'full' : 0,
    'half' : 0,
    'None' : 0
  };

  List<MemoryImage>? _imagesList = []; // Initialize the list


  _selectImageFromGallery(int index) async
  {
    var imageFilePickedFromGallery = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(imageFilePickedFromGallery != null)
    {
      MemoryImage imageFileInBytesForm = MemoryImage((File(imageFilePickedFromGallery.path)).readAsBytesSync());

      if(index < 0)
      {
        _imagesList ??= []; // Initialize if it's still null
        _imagesList!.add(imageFileInBytesForm);
      }
      else
      {
        _imagesList![index] = imageFileInBytesForm;
      }

      setState(() {});

    }
  }

  initializeValues()
  {
    if(widget.posting == null)
    {
      _nameTextEditingController = TextEditingController(text: "");
      _priceTextEditingController = TextEditingController(text: "");
      _descriptionTextEditingController = TextEditingController(text: "");
      _addressTextEditingController = TextEditingController(text: "");
      _cityTextEditingController = TextEditingController(text: "");
      _amenitiesTextEditingController = TextEditingController(text: "");
      residenceTypeSelected = residenceTypes.first;

      // _beds, _bathrooms, _kitchen, _furniture are now initialized with default values
      _beds =  {
        'small' : 0,
        'medium' : 0,
        'Large' : 0
      };
      _bathrooms =  {
        'small' : 0,
        'medium' : 0,
        'Large' : 0
      };
      _kitchen =  {
        'full' : 0,
        'half' : 0,
        'None' : 0
      };
      _furniture =  {
        'full' : 0,
        'half' : 0,
        'None' : 0
      };

      _imagesList = [];

    }
    else
    {
      _nameTextEditingController = TextEditingController(text: widget.posting!.name);
      _priceTextEditingController = TextEditingController(text: widget.posting!.price.toString());
      _descriptionTextEditingController = TextEditingController(text: widget.posting!.description);
      _addressTextEditingController = TextEditingController(text: widget.posting!.address);
      _cityTextEditingController = TextEditingController(text: widget.posting!.city);
      _amenitiesTextEditingController = TextEditingController(text: widget.posting!.getAmenitiesString());
      _beds = widget.posting!.beds!;
      _bathrooms = widget.posting!.bathrooms!;
      _kitchen = widget.posting!.kitchen!;
      _furniture = widget.posting!.furniture!;
      _imagesList = widget.posting!.displayImages;
      residenceTypeSelected = widget.posting!.type!;
    }

    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  @override
  Widget build(BuildContext context)
  {

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C3E50),
          ),
        ),
        title: const Text(
          "Create or Update a Posting",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async
            {
              if(!formkey.currentState!.validate())
              {
                return;
              }

              if(residenceTypeSelected == "")
              {
                return;
              }

              if(_imagesList == null || _imagesList!.isEmpty)
              {
                Get.snackbar("Error", "Please select at least one image", snackPosition: SnackPosition.TOP);
                return;
              }

              postingModel.name = _nameTextEditingController.text;
              postingModel.price = double.parse(_priceTextEditingController.text);
              postingModel.description = _descriptionTextEditingController.text;
              postingModel.address = _addressTextEditingController.text;
              postingModel.city = _cityTextEditingController.text;
              postingModel.amenities = _amenitiesTextEditingController.text.split(",");
              postingModel.type = residenceTypeSelected;
              postingModel.beds = _beds;
              postingModel.bathrooms = _bathrooms;
              postingModel.kitchen = _kitchen;
              postingModel.furniture = _furniture;
              postingModel.displayImages = _imagesList;

              postingModel.host = AppConstants.currentUser.createUserFromContact();
              postingModel.setImagesNames();

              //if this is a new post or old post to update
              if (widget.posting == null) {
                postingModel.rating = 3.5;
                postingModel.rentals = [];
                postingModel.reviews = [];
                try{
                  await postingViewModel.addListingInfoToFirestore();
                  await postingViewModel.addImagesToFirebaseStorage();
                  Get.snackbar(
                      "New Listing", "your new listing is uploaded successfully");
                } catch(e){
                  Get.snackbar("Error", "Failed to upload listing: $e", snackPosition: SnackPosition.TOP);
                  return; // Important: Exit if upload fails
                }


              }
              else
              {
                postingModel.rating = widget.posting!.rating;
                postingModel.rentals = widget.posting!.rentals;
                postingModel.reviews = widget.posting!.reviews;
                postingModel.id = widget.posting!.id;

                for (int i = 0;
                i < AppConstants.currentUser.myPostings!.length;
                i++) {
                  if (AppConstants.currentUser.myPostings![i].id ==
                      postingModel.id) {
                    AppConstants.currentUser.myPostings![i] = postingModel;
                    break;
                  }
                }
                try{
                  await postingViewModel.updatePostingInfoToFirestore();
                  Get.snackbar("Update Listing",
                      "your listing is updated successfully");
                } catch(e){
                Get.snackbar("Error", "Failed to update listing: $e", snackPosition: SnackPosition.TOP);
                  return;
                }
              }
              postingModel = PostingModel();

              Get.offAll(HostHomeScreen()); // Use offAll to prevent going back to this form on back press.
            },
            icon: const Icon(Icons.upload),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //Padding
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Listing name"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _nameTextEditingController,
                          validator: (textInput)
                          {
                            if (textInput!.isEmpty)
                            {
                              return "please enter a valid name";
                            }
                            return null;
                          },
                        ),
                      ),

                      //Select Property Type
                      Padding(
                        padding: const EdgeInsets.only(top: 28.0),
                        child: DropdownButton(
                          items: residenceTypes.map((item)
                          {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (valueItem)
                          {
                            setState(() {
                              residenceTypeSelected = valueItem.toString();
                            });
                          },
                          isExpanded: true,
                          value: residenceTypeSelected,
                          hint: const Text(
                            "Select Property Type",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),

                      // house pricing
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[

                            Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: "Price"),
                                  style: const TextStyle(
                                    fontSize: 25.0,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _priceTextEditingController,
                                  validator: (text){
                                    if(text!.isEmpty){
                                      return "please enter a valid price";
                                    }
                                    if(double.tryParse(text) == null){
                                      return "Invalid number";
                                    }
                                    return null;
                                  },
                                )
                            ),

                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0),
                              child: Text(
                                "₦ / month",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),

                      //Description
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Description"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _descriptionTextEditingController,
                          maxLines: 3,
                          minLines: 1,
                          validator: (text){
                            if(text!.isEmpty){
                              return "please enter a valid description";
                            }
                            return null;
                          },
                        ),
                      ),

                      //Address
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Address"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _addressTextEditingController,
                          validator: (text)
                          {
                            if (text!.isEmpty)
                            {
                              return "please enter a valid address (comma separated)";
                            }
                            return null;
                          },
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),

                      //Beds
                      const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Beds',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding:const EdgeInsets.only(top: 21.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: <Widget>[

                            //Twin/Single bedroom
                            AmenitiesUi(
                              type: 'Single',
                              startValue: _beds['small'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_beds['small']! > 0) {
                                    _beds['small'] = _beds['small']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _beds['small'] = _beds['small']! + 1;
                                });
                              },
                            ),

                            //Two Bedroom
                            AmenitiesUi(
                              type: 'Two Bedroom',
                              startValue: _beds['medium'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_beds['medium']! > 0) {
                                    _beds['medium'] = _beds['medium']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _beds['medium'] = _beds['medium']! + 1;
                                });
                              },
                            ),


                            //Three bedroom
                            AmenitiesUi(
                              type: 'Three Bedroom',
                              startValue: _beds['Large'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_beds['Large']! > 0) {
                                    _beds['Large'] = _beds['Large']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _beds['Large'] = _beds['Large']! + 1;
                                });
                              },
                            ),



                          ],
                        ),
                      ),

                      //bathrooms
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Bathrooms',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding:const EdgeInsets.only(top: 21.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: <Widget>[

                            //One bathroom
                            AmenitiesUi(
                              type: 'Single',
                              startValue: _bathrooms['small'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_bathrooms['small']! > 0) {
                                    _bathrooms['small'] = _bathrooms['small']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _bathrooms['small'] = _bathrooms['small']! + 1;
                                });
                              },
                            ),

                            //Two Bathroom
                            AmenitiesUi(
                              type: 'Two Bathroom',
                              startValue: _bathrooms['medium'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_bathrooms['medium']! > 0) {
                                    _bathrooms['medium'] = _bathrooms['medium']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _bathrooms['medium'] = _bathrooms['medium']! + 1;
                                });
                              },
                            ),


                            //Three bathroom
                            AmenitiesUi(
                              type: 'Three Bathroom',
                              startValue: _bathrooms['Large'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_bathrooms['Large']! > 0) {
                                    _bathrooms['Large'] = _bathrooms['Large']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _bathrooms['Large'] = _bathrooms['Large']! + 1;
                                });
                              },
                            ),



                          ],
                        ),
                      ),


                      //kitchen
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Kitchen',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding:const EdgeInsets.only(top: 21.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: <Widget>[

                            //Fully Furnished
                            AmenitiesUi(
                              type: 'Fully-Furnished',
                              startValue: _kitchen['full'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_kitchen['full']! > 0) {
                                    _kitchen['full'] = _kitchen['full']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _kitchen['full'] = _kitchen['full']! + 1;
                                });
                              },
                            ),

                            //Semi-Furnished
                            AmenitiesUi(
                              type: 'Semi-Furnished',
                              startValue: _kitchen['half'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_kitchen['half']! > 0) {
                                    _kitchen['half'] = _kitchen['half']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _kitchen['half'] = _kitchen['half']! + 1;
                                });
                              },
                            ),


                            //Not Furnished
                            AmenitiesUi(
                              type: 'Not-Furnished',
                              startValue: _kitchen['None'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_kitchen['None']! > 0) {
                                    _kitchen['None'] = _kitchen['None']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _kitchen['None'] = _kitchen['None']! + 1;
                                });
                              },
                            ),



                          ],
                        ),
                      ),

                      //Furniture
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Furniture',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding:const EdgeInsets.only(top: 21.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: <Widget>[

                            //Fully Furnished
                            AmenitiesUi(
                              type: 'Fully-Furnished',
                              startValue: _furniture['full'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_furniture['full']! > 0) {
                                    _furniture['full'] = _furniture['full']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _furniture['full'] = _furniture['full']! + 1;
                                });
                              },
                            ),

                            //Semi-Furnished
                            AmenitiesUi(
                              type: 'Semi-Furnished',
                              startValue: _furniture['half'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_furniture['half']! > 0) {
                                    _furniture['half'] = _furniture['half']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _furniture['half'] = _furniture['half']! + 1;
                                });
                              },
                            ),


                            //Not Furnished
                            AmenitiesUi(
                              type: 'Not-Furnished',
                              startValue: _furniture['None'] ?? 0,
                              decreaseValue: ()
                              {
                                setState(() {
                                  if (_furniture['None']! > 0) {
                                    _furniture['None'] = _furniture['None']! - 1;
                                  }
                                });
                              },
                              increaseValue: ()
                              {
                                setState(() {
                                  _furniture['None'] = _furniture['None']! + 1;
                                });
                              },
                            ),



                          ],
                        ),
                      ),

                      //extra amenities
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Amenities"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _amenitiesTextEditingController,
                          validator: (text)
                          {
                            if (text!.isEmpty)
                            {
                              return "please enter valid amenities (comma separated)";
                            }
                            return null;
                          },
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),

                      //listing images
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 25.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: (_imagesList?.length ?? 0) + 1, // Handle null _imagesList
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            childAspectRatio: 3 / 2,
                          ),
                          itemBuilder: (context, index)
                          {
                            if (index == (_imagesList?.length ?? 0)) // Handle null _imagesList
                                {
                              return IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _selectImageFromGallery(-1);
                                },
                              );
                            }
                            return MaterialButton(
                              onPressed: (){},
                              child: Image(
                                image: _imagesList![index],
                                fit: BoxFit.fill,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}