import { Controller } from "@hotwired/stimulus"

// Reusable category filter controller
// Can be used for both events and posts filtering
export default class extends Controller {
  static targets = ["pill", "item"]

  connect() {
    console.log(`Category filter controller connected`)
    console.log(`Found ${this.itemTargets.length} item targets`)
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
      
      // Show all items
      this.itemTargets.forEach(item => {
        item.classList.remove("hidden")
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
    
    // If no categories are selected, activate "All" and show all items
    if (activeCategories.length === 0) {
      this.pillTargets.find(p => p.dataset.category === "all").classList.add("active")
      this.itemTargets.forEach(item => {
        item.classList.remove("hidden")
      })
      return
    }
    
    // Filter items based on active categories
    this.itemTargets.forEach(item => {
      const itemCategory = item.dataset.category
      console.log(`Item category: ${itemCategory}, Active categories: ${activeCategories}`)
      if (activeCategories.includes(itemCategory)) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }
}
