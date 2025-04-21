using System;
using System.Collections.Generic;
using System.Text;

namespace CallTaxi.Model.Responses
{
    public class PagedResult<T>
    {
        public List<T> Items { get; set; } = new List<T>();
        public int? TotalCount { get; set; }
    }
} 
