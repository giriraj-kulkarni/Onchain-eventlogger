<template>
  <div class="bg-darkGray min-h-screen text-white font-sans">
    <!-- Navbar -->
    <nav class="bg-gradient-to-r from-purple-800 to-purple-600 p-4 flex justify-between items-center">
      <div class="text-xl font-bold">Web3 Logs</div>
      <div>
        <a href="#store-logs" class="px-3 py-2 hover:underline">Store Logs</a>
        <a href="#access-logs" class="px-3 py-2 hover:underline">Access Logs</a>
      </div>
    </nav>

    <!-- Hero Section -->
    <header class="text-center py-20 bg-darkPurple">
      <h1 class="text-4xl font-extrabold">Decentralized Event Logging</h1>
      <p class="text-xl mt-4 text-lightPurple">
        Store and access your logs securely on the blockchain
      </p>
    </header>

    <!-- Store Logs Section -->
    <section id="store-logs" class="py-10">
      <h2 class="text-2xl font-bold text-center">Store Logs</h2>
      <p class="text-center mt-2">Please click the button below to store your event logs on the blockchain.</p>
      
      <div class="text-center mt-4">
        <button @click="storeLogs" class="bg-purple-600 hover:bg-purple-700 text-white font-bold py-2 px-6 rounded-full">
          Store Logs
        </button>
      </div>
      <p v-if="storeStatus" class="text-center mt-4">{{ storeStatus }}</p>
    </section>

    <!-- Access Logs Section -->
    <section id="access-logs" class="py-10 bg-gray-800">
      <h2 class="text-2xl font-bold text-center">Access Logs</h2>
      <p class="text-center mt-2">Click below to access your event logs in PDF format.</p>

      <div class="text-center mt-4">
        <button @click="accessLogs" class="bg-purple-600 hover:bg-purple-700 text-white font-bold py-2 px-6 rounded-full">
          Access Logs as PDF
        </button>
      </div>
      <p v-if="accessStatus" class="text-center mt-4">{{ accessStatus }}</p>
    </section>

    <!-- Footer -->
    <footer class="bg-purple-900 text-center py-4 text-lightPurple">
      <p>&copy; 2024 Web3 Logs. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: "App",
  data() {
    return {
      storeStatus: null,
      accessStatus: null,
      userAddress: "0xYourUserAddressHere", // Replace with actual logic to get the user's address
    };
  },
  methods: {
    async storeLogs() {
      try {
        // Collect logs and duration (for simplicity, assume they're static here)
        const logs = "Sample Event Logs"; // Ideally, fetch logs dynamically or from local storage
        const duration = 7; // 7 days (for example)
        
        // Send request to backend to store logs on the blockchain
        const response = await axios.post('http://localhost:3000/store-logs', {
          logs,
          duration,
          userAddress: this.userAddress,
        });

        this.storeStatus = `Logs stored successfully! Transaction Hash: ${response.data.transactionHash}`;
      } catch (error) {
        this.storeStatus = `Error: ${error.response.data.error}`;
      }
    },

    async accessLogs() {
      try {
        // Send request to backend to access logs as PDF
        const response = await axios.post('http://localhost:3000/access-logs-pdf', {
          userAddress: this.userAddress,
        });

        this.accessStatus = `PDF Access granted! Transaction Hash: ${response.data.transactionHash}`;
      } catch (error) {
        this.accessStatus = `Error: ${error.response.data.error}`;
      }
    },
  },
};
</script>

<style scoped>
/* Scoped styles */
</style>
