// Oak & Iron Coffee — Scripts

document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const mobileToggle = document.getElementById('mobileToggle');
    const navLinks = document.getElementById('navLinks');

    if (mobileToggle && navLinks) {
        mobileToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
        });
    }

    // Smooth scroll for nav links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                // Close mobile menu if open
                navLinks.classList.remove('active');
            }
        });
    });

    // Form handling
    const signupForm = document.getElementById('signupForm');
    const formMessage = document.getElementById('formMessage');

    if (signupForm) {
        signupForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const emailInput = this.querySelector('input[type="email"]');
            const email = emailInput ? emailInput.value : '';

            // Basic validation
            if (!email || !email.includes('@')) {
                formMessage.textContent = 'Please enter a valid email address.';
                formMessage.style.color = '#f44336';
                return;
            }

            try {
                // Simulate submission
                formMessage.textContent = 'Thanks! Check your inbox for 10% off.';
                formMessage.style.color = '#4CAF50';
                this.reset();

                // Clear message after 5 seconds
                setTimeout(() => {
                    formMessage.textContent = '';
                }, 5000);
            } catch (err) {
                formMessage.textContent = 'Something went wrong. Please try again.';
                formMessage.style.color = '#f44336';
                console.error('Form error:', err);
            }
        });
    }

    // Sticky nav background on scroll
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.style.background = 'rgba(26, 26, 26, 0.95)';
        } else {
            navbar.style.background = 'var(--color-primary)';
        }
    });
});
