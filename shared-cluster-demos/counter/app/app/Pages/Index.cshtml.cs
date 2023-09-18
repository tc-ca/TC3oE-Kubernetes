using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace app.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public void OnGet()
    {

    }

    public IActionResult OnPostIncrease() {
        Count = ++GlobalCount;
        Bump = true;
        return Page();
    }

    public IActionResult OnPostReset() {
        Count = GlobalCount = 0;
        Bump = true;
        return Page();
    }

    public bool Bump {get; set;} = false;

    public int Count {get; set;} = GlobalCount;
    public static int GlobalCount = 0;
}
