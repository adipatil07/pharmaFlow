import 'package:flutter/material.dart';
import 'package:pharma_supply/features/manufacturer/notifier/add_product_provider.dart';
import 'package:provider/provider.dart';
import 'package:pharma_supply/constants/app_theme.dart';

class AddProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductProvider(),
      child: Consumer<AddProductProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Text(
                'Product Form',
                style: AppTheme.headlineTextStyle
                    .copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: provider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField(
                        'Product Name', provider.productNameController),
                    buildTextField(
                        'Batch Number', provider.batchNumberController),
                    buildTextField(
                        'Composition', provider.compositionController),
                    buildTextField('Ingredients (comma-separated)',
                        provider.ingredientsController),
                    buildDatePicker(context, 'Manufacturing Date',
                        isManufacturing: true, provider: provider),
                    buildDatePicker(context, 'Expiry Date',
                        isManufacturing: false, provider: provider),
                    buildTextField(
                        'Dosage Form', provider.dosageFormController),
                    buildTextField(
                        'Packaging Type', provider.packagingTypeController),
                    buildTextField('Storage Conditions',
                        provider.storageConditionsController),
                    buildTextField('Directions for Use',
                        provider.directionsForUseController),
                    buildTextField(
                        'Indications', provider.indicationsController),
                    buildTextField('Contraindications (comma-separated)',
                        provider.contraindicationsController),
                    buildTextField('Precautions (comma-separated)',
                        provider.precautionsController),
                    buildTextField('Side Effects (comma-separated)',
                        provider.sideEffectsController),
                    buildTextField('Manufacturer Name',
                        provider.manufacturerNameController),
                    buildTextField('Manufacturer Address',
                        provider.manufacturerAddressController),
                    buildTextField('Regulatory Approval Number',
                        provider.regulatoryApprovalNumberController),
                    buildTextField(
                        'Net Weight (g)', provider.netWeightController,
                        keyboardType: TextInputType.number),
                    buildTextField('Color', provider.colorController),
                    buildTextField('Shape', provider.shapeController),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: AppTheme.elevatedButtonStyle,
                      onPressed: provider.showLoadingOnButton
                          ? null
                          : () async {
                              await provider.submitForm(context);
                            },
                      child: provider.showLoadingOnButton
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('ADD PRODUCT',
                              style: AppTheme.buttonTextStyle),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTheme.inputTextStyle,
        keyboardType: keyboardType,
        decoration: AppTheme.inputDecoration.copyWith(
          labelText: label,
          labelStyle: AppTheme.inputTextStyle,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget buildDatePicker(BuildContext context, String label,
      {required bool isManufacturing, required AddProductProvider provider}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyTextStyle),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blueAccent.withOpacity(0.5)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(16)),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              elevation: MaterialStateProperty.all<double>(5),
            ),
            onPressed: () => provider.selectDate(context, isManufacturing),
            child: Text(
              isManufacturing
                  ? (provider.manufacturingDate != null
                      ? provider.manufacturingDate!
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                      : 'Select Date')
                  : (provider.expiryDate != null
                      ? provider.expiryDate!.toLocal().toString().split(' ')[0]
                      : 'Select Date'),
            ),
          ),
        ],
      ),
    );
  }
}
