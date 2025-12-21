import ContactForm from './components/ContactForm';

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-blue-600 text-white p-6 text-center">
        <h1 className="text-3xl font-bold">Yisak Mesifin</h1>
        <p>Cloud Engineer & Automation Specialist</p>
      </header>
      <main>
        <ContactForm />
      </main>
    </div>
  );
}

export default App;