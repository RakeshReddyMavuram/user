import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:user/Components/bottom_bar.dart';
import 'package:user/Components/entry_field.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';

class CustomDeliveryPage extends StatelessWidget {
  final String pageTitle;

  CustomDeliveryPage(this.pageTitle);

  @override
  Widget build(BuildContext context) {
    return CustomDelivery(pageTitle);
  }
}

class CustomDelivery extends StatefulWidget {
  final String pageTitle;

  CustomDelivery(this.pageTitle);

  @override
  _CustomDeliveryState createState() => _CustomDeliveryState();
}

class _CustomDeliveryState extends State<CustomDelivery> {
  // CustomDeliveryBloc _deliveryBloc;
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropController = TextEditingController();
  TextEditingController valuesController = TextEditingController();
  TextEditingController instructionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _deliveryBloc = BlocProvider.of<CustomDeliveryBloc>(context);
  }

  @override
  void dispose() {
    pickUpController.dispose();
    dropController.dispose();
    valuesController.dispose();
    instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Send Package'),
        titleSpacing: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Divider(
                thickness: 10.0,
                color: kCardBackgroundColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    //pickUpController.text = state.pickupAddress;
                    EntryField(
                      controller: pickUpController,
                      image: 'images/custom/ic_pickup_pointact.png',
                      label: 'PICKUP ADDRESS',
                      hint: 'Enter Pickup Location',
                      onTap: () {/*...........*/},
                      readOnly: true,
                    ),
                    EntryField(
                      controller: dropController,
                      image: 'images/custom/ic_droppointact.png',
                      label: 'DROP ADDRESS',
                      hint: 'Enter Drop Location',
                      readOnly: true,
                      onTap: () {/*.......*/},
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 10.0,
                color: kCardBackgroundColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: EntryField(
                  controller: valuesController,
                  image: 'images/custom/ic_packageact.png',
                  label: 'SELECT PACKAGE TYPE',
                  hint: 'Select type of package',
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: kMainColor,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ModalBottomWidget();
                      },
                    );
                  },
                ),
              ),
              Divider(
                thickness: 10.0,
                color: kCardBackgroundColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EntryField(
                  hint: 'Any instruction? E.g Carry package carefully',
                  image: 'images/custom/ic_instruction.png',
                  border: InputBorder.none,
                ),
              ),
              Divider(
                thickness: 10.0,
                color: kCardBackgroundColor,
              ),
              Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text('PAYMENT INFO',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: kDisabledColor)),
                color: Colors.white,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Delivery Charge',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        '\$ 0.00',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Service Fee',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        '\$ 0.00',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Amount to Pay',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$ 0.00',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              SizedBox(
                height: 5.0,
              ),
              BottomBar(
                text: 'Continue',
                onTap: () {
                  Navigator.pushNamed(context, PageRoutes.paymentMethod);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//bottom sheets that pops up on select package type field
class ModalBottomWidget extends StatelessWidget {
  final List<String> list = <String>[
    'Paper & Documents',
    'Flowers & Chocolates',
    'Sports & Toys item',
    'Clothes & Accessories',
    'Electronic item',
    'Household item',
    'Glass item',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          color: kCardBackgroundColor,
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Select Package Type',
                style: Theme.of(context).textTheme.headline4,
              ),
              RaisedButton(
                child: Text('Done'),
                onPressed: () {
                  //_deliveryBloc.add(ValuesShowEvent());
                  Navigator.pop(context);
                },
                disabledTextColor: kLightTextColor,
                shape: OutlineInputBorder(
                    borderSide: BorderSide(color: kTransparentColor),
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ],
          ),
        ),
        CheckboxGroup(
          labelStyle: Theme.of(context).textTheme.caption,
          //labels: _deliveryBloc.list,
          padding: EdgeInsets.only(top: 16.0),
          onSelected: (List<String> checked) {}, labels: list,
        ),
      ],
    );
  }
}
