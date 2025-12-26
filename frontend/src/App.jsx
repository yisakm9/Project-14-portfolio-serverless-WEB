import ContactForm from './components/ContactForm';
import Projects from './components/Projects';

function App() {
  return (
    <div className="min-h-screen bg-gray-50 font-sans text-gray-900">
      {/* Hero Section */}
      <header className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white py-20 px-6 text-center">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">Yisak Mesifin</h1>
        <p className="text-xl md:text-2xl font-light mb-8">Cloud Engineer & Automation Specialist</p>
        <div className="flex justify-center gap-4">
          <a href="#projects" className="bg-white text-blue-700 px-6 py-2 rounded-full font-bold hover:bg-gray-100 transition">View Projects</a>
          <a href="#contact" className="border-2 border-white px-6 py-2 rounded-full font-bold hover:bg-white hover:text-blue-700 transition">Contact Me</a>
        </div>
      </header>

      <main>
        {/* Dynamic Projects Section */}
        <Projects />

        {/* Contact Section */}
        <div id="contact">
          <ContactForm />
        </div>
      </main>
      
      <footer className="bg-gray-800 text-gray-400 py-6 text-center mt-12">
        <p>© 2025 Yisak Mesifin. Deployed via Terraform & GitHub Actions.</p>
      </footer>
    </div>
  );
}

export default App;