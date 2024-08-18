/*class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        // Handle the case where the user did not grant the permission
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;

        // Assuming the QR code contains the userId
        String? userId = result!.code;

        // TODO: Fetch the subscriptionLevel for this user
        String subscriptionLevel =
            "Subscriber"; // This is just a placeholder. Fetch the actual value.

        // TODO: Define the businessId
        String businessId =
            "your_business_id"; // Replace with the actual businessId

        // Record the check-in
        QRScannerLogic().recordCheckIn(businessId, userId!, subscriptionLevel);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
              _buildQROverlay(),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: result != null
                ? Text(
                    'Data: ${result!.code}',
                    style: const TextStyle(fontSize: 16),
                  )
                : const Text('Scan a QR code',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildQROverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double crosshairSize = 30.0; // Adjust as needed
        double crosshairWidth = 4.0; // Adjust as needed
        double cornerLength = 20.0; // Adjust as needed
        double cornerThickness = 5.0; // Adjust as needed
        double borderWidth = 4.0;

        return Stack(
          children: [
            // Top dark overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: constraints.maxHeight * 0.25,
                color: Colors.black54,
              ),
            ),
            // Bottom dark overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: constraints.maxHeight * 0.25,
                color: Colors.black54,
              ),
            ),
            // Left dark overlay
            Positioned(
              top: constraints.maxHeight * 0.25,
              bottom: constraints.maxHeight * 0.25,
              left: 0,
              child: Container(
                width: constraints.maxWidth * 0.15,
                color: Colors.black54,
              ),
            ),
            // Right dark overlay
            Positioned(
              top: constraints.maxHeight * 0.25,
              bottom: constraints.maxHeight * 0.25,
              right: 0,
              child: Container(
                width: constraints.maxWidth * 0.15,
                color: Colors.black54,
              ),
            ),
            // Top border
            Positioned(
              top: constraints.maxHeight * 0.25 - borderWidth,
              left: constraints.maxWidth * 0.14,
              right: constraints.maxWidth * 0.14,
              child: Container(
                color: Colors.purple,
                height: borderWidth,
              ),
            ),
            // Bottom border
            Positioned(
              bottom: constraints.maxHeight * 0.25 - borderWidth,
              left: constraints.maxWidth * 0.14,
              right: constraints.maxWidth * 0.14,
              child: Container(
                color: Colors.purple,
                height: borderWidth,
              ),
            ),
            // Left border
            Positioned(
              top: constraints.maxHeight * 0.25,
              bottom: constraints.maxHeight * 0.25,
              left: constraints.maxWidth * 0.15 - borderWidth,
              child: Container(
                color: Colors.purple,
                width: borderWidth,
              ),
            ),
            // Right border
            Positioned(
              top: constraints.maxHeight * 0.25,
              bottom: constraints.maxHeight * 0.25,
              right: constraints.maxWidth * 0.15 - borderWidth,
              child: Container(
                color: Colors.purple,
                width: borderWidth,
              ),
            ),
            // Company logo in the top overlay
            Positioned(
              top: (constraints.maxHeight * 0.25) / 2 -
                  50, // Adjusting for a 100x100 logo, change as needed
              left: (constraints.maxWidth - 100) /
                  2, // Centering the logo, adjust if your logo has a different size
              child: Image.asset(
                'assets/images/Asset_6.png', // Replace with the path to your logo
                width: 90, // Adjust as needed
                height: 90, // Adjust as needed
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}*/
