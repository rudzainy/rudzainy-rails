import { Controller } from "@hotwired/stimulus"

// Reusable category filter controller
// Can be used for both events and posts filtering
export default class extends Controller {
  static targets = ["pill", "item"]

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
    
    // Filter items based on active categories
    this.filterItemsByCategories(activeCategories)
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
    
    // Show all items
    this.showAllItems()
  }
  
  showAllItems() {
    this.itemTargets.forEach(item => {
      item.classList.remove("hidden")
    })
  }
  
  filterItemsByCategories(activeCategories) {
    this.itemTargets.forEach(item => {
      const itemCategory = item.dataset.category
      
      // Use string comparison to check if the item category is in the active categories
      const matches = activeCategories.some(activeCategory => {
        return activeCategory.toString() === itemCategory.toString()
      })
      
      if (matches) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }
}
