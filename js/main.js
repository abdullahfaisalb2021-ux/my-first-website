/* GAMEZONE — shared site behaviour */
(function () {
  "use strict";

  /* ------------------------------------------------------------------
     Mobile navigation toggle
     ------------------------------------------------------------------ */
  var navToggle = document.querySelector(".nav-toggle");
  var mainNav = document.getElementById("main-nav");

  if (navToggle && mainNav) {
    var closeNav = function () {
      mainNav.classList.remove("is-open");
      navToggle.setAttribute("aria-expanded", "false");
    };

    navToggle.addEventListener("click", function () {
      var isOpen = mainNav.classList.toggle("is-open");
      navToggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
    });

    // Close the panel after choosing a destination
    mainNav.addEventListener("click", function (event) {
      if (event.target.closest("a")) {
        closeNav();
      }
    });

    // Close on Escape and return focus to the toggle button
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && mainNav.classList.contains("is-open")) {
        closeNav();
        navToggle.focus();
      }
    });

    // Close when tapping outside the header
    document.addEventListener("click", function (event) {
      if (
        mainNav.classList.contains("is-open") &&
        !event.target.closest(".main-nav") &&
        !event.target.closest(".nav-toggle")
      ) {
        closeNav();
      }
    });
  }

  /* ------------------------------------------------------------------
     Contact form validation (client-side only)
     ------------------------------------------------------------------ */
  var form = document.getElementById("contact-form");

  if (form) {
    var status = document.getElementById("form-status");

    var validators = {
      name: function (value) {
        return value.trim().length >= 2
          ? ""
          : "Please enter your name (at least 2 characters).";
      },
      email: function (value) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value.trim())
          ? ""
          : "Please enter a valid email address, like player@example.com.";
      },
      topic: function (value) {
        return value ? "" : "Please choose a topic so we route it correctly.";
      },
      message: function (value) {
        return value.trim().length >= 20
          ? ""
          : "Please tell us a bit more (at least 20 characters).";
      },
    };

    var showError = function (input, message) {
      var field = input.closest(".field");
      var error = field.querySelector(".field__error");
      if (message) {
        field.classList.add("has-error");
        error.textContent = message;
        input.setAttribute("aria-invalid", "true");
        input.setAttribute("aria-describedby", error.id);
      } else {
        field.classList.remove("has-error");
        error.textContent = "";
        input.removeAttribute("aria-invalid");
        input.removeAttribute("aria-describedby");
      }
    };

    var validateField = function (input) {
      var validator = validators[input.name];
      if (!validator) return true;
      var message = validator(input.value);
      showError(input, message);
      return !message;
    };

    // Validate a field once the user has finished with it
    form.addEventListener(
      "blur",
      function (event) {
        if (event.target.matches(".field__input")) {
          validateField(event.target);
        }
      },
      true
    );

    // Re-validate as the user types after an error was shown
    form.addEventListener("input", function (event) {
      if (event.target.closest(".field.has-error")) {
        validateField(event.target);
      }
    });

    form.addEventListener("submit", function (event) {
      event.preventDefault();

      var inputs = form.querySelectorAll(".field__input");
      var firstInvalid = null;
      var valid = true;

      inputs.forEach(function (input) {
        if (!validateField(input) && !firstInvalid) {
          firstInvalid = input;
        }
        if (input.getAttribute("aria-invalid")) {
          valid = false;
        }
      });

      if (!valid) {
        status.textContent =
          "Some fields need attention. Please review the highlighted items.";
        status.className = "form-status form-status--error";
        if (firstInvalid) firstInvalid.focus();
        return;
      }

      status.textContent =
        "Transmission received. A GAMEZONE operator will reply within 24 hours.";
      status.className = "form-status form-status--success";
      form.reset();
    });
  }

  /* ------------------------------------------------------------------
     Footer year
     ------------------------------------------------------------------ */
  document.querySelectorAll("[data-year]").forEach(function (el) {
    el.textContent = String(new Date().getFullYear());
  });
})();
