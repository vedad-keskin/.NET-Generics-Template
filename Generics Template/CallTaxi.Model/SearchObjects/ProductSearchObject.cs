﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CallTaxi.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? Code { get; set; }

        public string? CodeGTE { get; set; }
    }
}
