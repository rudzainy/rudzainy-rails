import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-filter"
export default class extends Controller {
  static targets = ["pill", "event"]

  connect() {
    // Controller initialization
  }

  toggle(event) {
    const pill = event.currentTarget
    const category = pill.dataset.category
    
    if (category === "all") {
      this.handleAllCategory()
      return
    }
    
    // Toggle the clicked category pill
    pill.classList.toggle("active")
    
    // Deactivate "All" pill when a specific category is selected
    this.getAllPill().classList.remove("active")
    
    // Get all currently active categories
    const activeCategories = this.getActiveCategories()
    
    // If no categories are selected, revert to "All"
    if (activeCategories.length === 0) {
      this.handleAllCategory()
      return
    }
    
    // Filter events based on active categories
    this.filterEventsByCategories(activeCategories)
  }
  
  // Helper methods
  getAllPill() {
    return this.pillTargets.find(p => p.dataset.category === "all")
  }
  
  getActiveCategories() {
    return Array.from(this.pillTargets)
      .filter(p => p.classList.contains("active"))
      .map(p => p.dataset.category)
  }
  
  handleAllCategory() {
    // Reset all pills
    this.pillTargets.forEach(p => {
      if (p.dataset.category === "all") {
        p.classList.add("active")
      } else {
        p.classList.remove("active")
      }
    })
    
    // Show all events
    this.showAllEvents()
  }
  
  showAllEvents() {
    this.eventTargets.forEach(eventElement => {
      eventElement.classList.remove("hidden")
    })
  }
  
  filterEventsByCategories(activeCategories) {
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
