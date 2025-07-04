import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-filter"
export default class extends Controller {
  static targets = ["pill", "event"]

  connect() {
    console.log("Event filter controller connected")
    console.log(`Found ${this.eventTargets.length} event targets`)
    console.log(`Found ${this.pillTargets.length} pill targets`)
  }

  toggle(event) {
    const pill = event.currentTarget
    const category = pill.dataset.category
    
    // Handle "All" category
    if (category === "all") {
      // Reset all pills
      this.pillTargets.forEach(p => {
        if (p.dataset.category === "all") {
          p.classList.add("active")
        } else {
          p.classList.remove("active")
        }
      })
      
      // Show all events
      this.eventTargets.forEach(eventElement => {
        eventElement.classList.remove("hidden")
      })
      return
    }
    
    // Handle category selection
    const isActive = pill.classList.toggle("active")
    
    // Deactivate "All" pill when a category is selected
    this.pillTargets.find(p => p.dataset.category === "all").classList.remove("active")
    
    // Get all active categories
    const activeCategories = Array.from(this.pillTargets)
      .filter(p => p.classList.contains("active"))
      .map(p => p.dataset.category)
    
    // If no categories are selected, activate "All" and show all events
    if (activeCategories.length === 0) {
      this.pillTargets.find(p => p.dataset.category === "all").classList.add("active")
      this.eventTargets.forEach(eventElement => {
        eventElement.classList.remove("hidden")
      })
      return
    }
    
    // Filter events based on active categories
    this.eventTargets.forEach(eventElement => {
      const eventCategory = eventElement.dataset.category
      if (activeCategories.includes(eventCategory)) {
        eventElement.classList.remove("hidden")
      } else {
        eventElement.classList.add("hidden")
      }
    })
  }
}
