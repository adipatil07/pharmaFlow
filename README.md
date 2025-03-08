# **PharmaFlow 🚀**  
**A blockchain-inspired order tracking system for pharmaceutical supply chain management, built with Flutter and Firebase.**  

## **📌 Overview**  
PharmaFlow is a **Flutter-based** pharmaceutical supply chain app designed to streamline order tracking between **manufacturers, transporters, hospitals, and patients**. It ensures **secure, immutable order updates** using a **blockchain-like structure in Firestore**, making the supply chain transparent and tamper-proof.  

## **🛠 Tech Stack**  
- **Flutter** – Frontend framework for mobile UI  
- **Firebase Firestore** – Cloud NoSQL database for storing order data  
- **Firebase Authentication** – Role-based access for manufacturers, transporters, hospitals, and patients  
- **Notifier State Management** – Efficient and scalable state handling  

## **🔗 Blockchain-Like Order Tracking in Firestore**  
PharmaFlow **mimics blockchain principles** in Firestore by maintaining an immutable order history:  
1. **Each order update** (e.g., "Picked Up", "In Transit") is stored as a **new block** in Firestore.  
2. Each block contains:  
   - `orderId`: Unique identifier of the order.  
   - `status`: Current status of the order.  
   - `by`: The entity making the update (e.g., Transporter, Manufacturer).  
   - `timestamp`: Exact time of modification.  
3. **Order tracking history is tamper-proof** – Old statuses remain **unaltered**.  

## **🚀 Features**  
✅ **Role-Based Authentication** – Separate dashboards for manufacturers, transporters, hospitals, and patients.  
✅ **Immutable Order Updates** – Tracks the full journey of medicine orders.  
✅ **Firestore-Backed Transactions** – Ensures data consistency and security.  
✅ **Efficient State Management** – Uses Notifier for real-time updates.  

## 📸 Screenshots & GIFs  
<img src="https://github.com/user-attachments/assets/42e310ac-4b1a-4f39-97c4-199519bcd117" width="400">
<img src="https://github.com/user-attachments/assets/7a7117d3-e4c8-4d11-97fb-32ec9f4020b7" width="400">


## **⚡ Installation Guide**  
1. **Clone the repository**  
   ```sh
   git clone https://github.com/yourusername/PharmaFlow.git
   cd PharmaFlow
   ```  
2. **Install dependencies**  
   ```sh
   flutter pub get
   ```  
3. **Run the app**  
   ```sh
   flutter run
   ```  

## **👨‍💻 Contributors**  
**[Aditya Patil](https://github.com/adipatil07)** – Flutter Developer  
