import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/constants.dart';
import 'package:pharma_supply/features/transporter/model/products_order_model.dart';
import 'package:pharma_supply/features/transporter/model/transporter_model.dart';

// class TransporterHomePage extends StatelessWidget {
//   const TransporterHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text("Transporter Home Page"),
//       ),
//     );
//   }
// }

class TransporterHomePage extends StatefulWidget {
  const TransporterHomePage({super.key});

  @override
  State<TransporterHomePage> createState() => _TransporterHomePageState();
}

class _TransporterHomePageState extends State<TransporterHomePage> {
  static TransporterModel dummyTransporter = TransporterModel(
    transporterId: "T123",
    transporterName: "Fast Express",
    transporterContact: "+1234567890",
  );

  // Create a dummy Order
  ProductOrderModel dummyOrder = ProductOrderModel(
    orderId: "O456",
    orderNumber: 789,
    clientId: "C789",
    clientName: "John Doe Pharma",
    manufacturerId: "MANU_4241",
    manufacturerName: "Cipla Pharmacy",
    registrationNumber: "REG987654",
    orderContentsList: ["Medicine A", "Medicine B", "Equipment C"],
    orderDate: DateTime.now(),
    assignedTransporter: dummyTransporter,
    deliveryStatus: "In Transit",
    deliveryStatusId: "DS123",
  );

  int screenSelected = 0; // 0 - Active, 1 - Past

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Icon(
                      Icons.account_tree_outlined,
                      color: Colors.orange,
                      size: 55,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "OrderDetails Page",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  orderTypeTile("Active", screenSelected == 0,
                      Icons.hourglass_bottom_outlined, 0),
                  orderTypeTile("Past", screenSelected == 1,
                      Icons.access_time_outlined, 1),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 10),
                  itemCount: 5, // Adjust based on the number of items
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: orderListTile(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  orderTypeTile(String text, bool isSelected, IconData icon, int screeIndex) {
    return Material(
      color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        onTap: () {
          setState(() {
            screenSelected = screeIndex;
          });
        },
        splashColor: Colors.blue,
        highlightColor: Colors.blue,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              color: isSelected ? Colors.blue : Colors.transparent,
              boxShadow: [
                BoxShadow(
                    color: isSelected ? Colors.black45 : Colors.transparent,
                    spreadRadius: 1,
                    blurRadius: 5)
              ]),
          width: 160,
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                text,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                    fontSize: 30),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  orderListTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
              ]),
          width: MediaQuery.of(context).size.width * 0.95,
          // height: 230,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    color: Colors.white,
                    height: 75,
                    width: 75,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          height: 70,
                          width: 70,
                        ),
                        Image.network(
                          Constants.PACKAGE_BOX_URL,
                          width: 70,
                          height: 70,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amazon",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 25),
                      ),
                      Text(
                        "U942092454-01041",
                        style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w400,
                            fontSize: 18),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.qr_code,
                        color: Colors.black,
                        size: 35,
                      )),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey.withOpacity(0.2),
                height: 2,
                endIndent: 10,
                indent: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "Order Number",
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "#5458",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Transporter",
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "FedEx(Pune)",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "In-Transit",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey.withOpacity(0.2),
                height: 2,
                endIndent: 10,
                indent: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      "${dummyOrder.clientName.substring(0, 1)}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${dummyOrder.clientName}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "Client ID : ${dummyOrder.clientId}",
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
