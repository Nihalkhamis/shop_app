import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product";

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController =
      TextEditingController(); // to save value of url to be updated in the image container and the image will be shown
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageFocusNode.addListener(
        _updateImageUrl); // when we type anywhere outside the TextFomField the image will be updated automatically
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null) {
      _editedProduct = Provider.of<Products>(context).getById(productId);
      _imageUrlController.text = _editedProduct.imageUrl!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith("jpg") &&
              !_imageUrlController.text.endsWith("png") &&
              !_imageUrlController.text.endsWith("jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValidate =
        _form.currentState?.validate(); // return true if there is no error msg
    if (!isValidate!) {
      return;
    }
    _form.currentState
        ?.save(); // this will execute OnSave: on every TextFormField
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      // so edit product pressed
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id!, _editedProduct);

      Navigator.of(context).pop();
    } else {
      // so add new product pressed
      try {
        await Provider.of<Products>(context, listen: false)
            .addItem(_editedProduct);
      }
      catch(error) {
        await showDialog<Null>(      // we put return (or await) here to return only if the user press okay then execute code inside then()
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("An error occurred!"),
                content: const Text("Something went wrong"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text("okay")),
                ],
              );
      });
      }
      // finally{
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
  }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product"), actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveForm,
        ),
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  // if form is long so better to use Column + SingleChildScrollView to keep the user inputs
                  children: [
                    TextFormField(
                      initialValue: _editedProduct.title,
                      decoration: const InputDecoration(label: Text("title")),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _editedProduct = Product(
                            isFav: _editedProduct.isFav,
                            id: _editedProduct.id,
                            title: value!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.price != null
                          ? _editedProduct.price.toString()
                          : "",
                      decoration: const InputDecoration(label: Text("price")),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a number';
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number above zero";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            isFav: _editedProduct.isFav,
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value!),
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.description,
                      decoration:
                          const InputDecoration(label: Text("description")),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return "Please enter at least 10 characters";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            isFav: _editedProduct.isFav,
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: value!,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text("Enter an image url")
                              : FittedBox(
                                  fit: BoxFit.cover,
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                        Expanded(
                          // here we use Expanded cz TextFormField by default takes as much width as it can but Row doesn't have unconstrained width(doesn't have the device boundaries)
                          child: TextFormField(
                            keyboardType: TextInputType.url,
                            decoration:
                                const InputDecoration(labelText: "Image URL"),
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              // this to force flutter to update the screen after changing the url
                              setState(() {});
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter an url";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid url";
                              }
                              if (!value.endsWith("jpg") &&
                                  !value.endsWith("png") &&
                                  !value.endsWith("jpeg")) {
                                return "Please enter a valid url";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  isFav: _editedProduct.isFav,
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value!);
                            },
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
